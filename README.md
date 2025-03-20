## O Desafio - Carrinho de compras
O desafio consiste em uma API para gerenciamento do um carrinho de compras de e-commerce.

Você deve desenvolver utilizando a linguagem Ruby e framework Rails, uma API Rest que terá 3 endpoins que deverão implementar as seguintes funcionalidades:

### O que esperamos
- Implementação dos testes faltantes e de novos testes para os métodos/serviços/entidades criados
- Construção das 4 rotas solicitadas
- Implementação de um job para controle dos carrinhos abandonados

### Detalhes adicionais:
- O Job deve ser executado regularmente para verificar e marcar carrinhos como abandonados após 3 horas de inatividade.
- O Job também deve verificar periodicamente e excluir carrinhos que foram marcados como abandonados por mais de 7 dias.

### Dependências
- ruby 3.3.1
- rails 7.1.3.2
- postgres 16
- redis 7.0.15

--------------------------------------------------------------------------------------------------------------------

Projeto Dockerizado.
Para rodar:
1 - docker-compose up --build

2 - (Se necessário) - 
docker-compose run app bundle exec rake db:create 
docker-compose run app bundle exec rake db:migrate
docker-compose run app bundle exec rake db:seed


docker-compose up

Para rodar os testes:
docker-compose exec app bundle exec bash
bin/rails spec


Testando manualmente:
*Cobri os cenários de erros, o roteiro irá primeiro passar por todas as chamadas corretas e depois pelos cenários erroneos.
**Fiz duas formas de se comunicar. A primeira usando a própria session, que seria o padrão no uso de um cliente
E a segunda utilizando diretamente os parametros de ID via API. A segunda é a forma mais fácil e com mais liberdade pra explorar os cenários.

*Via ID

- Objetivo 1: Registrar produto no carrinho

curl -X POST http://localhost:3000/carts \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": 1,
    "quantity": 2
  }'

Esperado:
{
  "id": 1,
  "status": "active",
  "products": [{"id":1,"name":"Samsung Galaxy S24 Ultra","quantity":3,"unit_price":12999.99,"total_price":38999.97}],
  "total_price": 0.0
}

- Objetivo 2: Listar itens do carrinho
curl -X GET http://localhost:3000/carts/1  (verificar o ID criado anteriormente)
Esperado:
{
  "id": 1,
  "status": "active",
  "products": [{"id":1,"name":"Samsung Galaxy S24 Ultra","quantity":3,"unit_price":12999.99,"total_price":38999.97}],
  "total_price": x.x
}

- Objetivo 3: Alterar a quantidade de produtos no carrinho
curl -X POST http://localhost:3000/carts/1205/update_item \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": 345,
    "quantity": 1
  }'

Esperado:
{
  "id": 1,
  "status": "active",
  "products": [
    {
      "id": 345,
      "name": "Nome do produto",
      "quantity": 3,
      "unit_price": 1.99,
      "total_price": 5.97
    }
  ],
  "total_price": 5.97
}

- Objetivo 4: Remover um produto do carrinho
curl -X DELETE http://localhost:3000/carts/1/remove_item/345

Esperado:
{
  "id": 1,
  "status": "active",
  "products": [],
  "total_price": 0.0
}

Cenários de erros:
- 1 
curl -X POST http://localhost:3000/carts \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": 99999,
    "quantity": 2
  }'

Esperado:
{
  "error": "Produto não encontrado"
}

3-
curl -X POST http://localhost:3000/carts/1/update_item \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": 99999,
    "quantity": 2
  }'

Esperado:
{
  "error": "Produto não encontrado no carrinho"
}

4-
curl -X DELETE http://localhost:3000/carts/1/remove_item/99999
{
  "error": "Produto não encontrado no carrinho"
}


*Diretamente via sessão
- Objetivo 1:
curl -X POST http://localhost:3000/carts \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": 3,
    "quantity": 2
  }' -c cookies.txt

Esperado:
{
  "id": 1,
  "status": "active",
  "products": [],
  "total_price": 0.0
}

- Objetivo 2:
curl -X GET http://localhost:3000/cart \
  -b cookies.txt

Esperado:
{
  "id": 1,
  "status": "active",
  "products": [array],
  "total_price": 0.0
}

- Objetivo 3:
curl -X POST http://localhost:3000/cart/update_item \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": 3,
    "quantity": 1
  }' -b cookies.txt

Esperado:
{
  "id": 1,
  "status": "active",
  "products": [
    {
      "id": 345,
      "name": "Nome do produto",
      "quantity": 3,
      "unit_price": 1.99,
      "total_price": 5.97
    }
  ],
  "total_price": 5.97
}

- Objetivo 4:
curl -X DELETE http://localhost:3000/cart/remove_item/3 \
  -b cookies.txt

{
  "id": 1,
  "status": "active",
  "products": [],
  "total_price": 0.0
}

Cenário de erros:
1 -
curl -X POST http://localhost:3000/carts \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": 99999,
    "quantity": 2
  }' -b cookies.txt

Esperado:
{
  "error": "Produto não encontrado"
}

3 -
curl -X POST http://localhost:3000/cart/update_item \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": 99999,
    "quantity": 2
  }' -b cookies.txt

Esperado:
{
  "error": "Produto não encontrado no carrinho"
}

4 -
curl -X DELETE http://localhost:3000/cart/remove_item/99999 \
  -b cookies.txt

{
  "error": "Produto não encontrado no carrinho"
}


Objetivo 5 (JOBS)
Os jobs contam com testes automatizados, mas caso queria conferir manualmente:

docker-compose exec app bundle exec rails console

Criando um carrinho para regra de 3 horas de inatividade:
cart = Cart.create!(total_price: 0.0, last_interaction_at: 4.hours.ago)
cart.update!(status: "active") 

Criando um carrinho para regra de 7 dias de abandono:
cart_to_remove = Cart.create!(total_price: 0.0, last_interaction_at: 8.days.ago)
cart_to_remove.update!(status: "abandoned")

Rodando os jobs manualmente:
MarkCartAsAbandonedJob.new.perform
DeleteAbandonedCartsJob.new.perform

Verificando resultados:
cart.reload.status (Esperado: abandono)
Cart.exists?(cart_to_remove.id) (Esperado: false)

Pode acompanhar a execução via sidekiq.