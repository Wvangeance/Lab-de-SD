# Especificação do Projeto: Máquina de Vendas

Este documento descreve a especificação de uma Máquina de Vendas Automática implementada em VHDL, utilizando uma Máquina de Estados Finitos (FSM) em nível RTL. O projeto tem como objetivo controlar a lógica de seleção, pagamento, entrega e reposição de produtos.

---

## ⚙️ Funcionamento Geral do Sistema

A máquina de vendas foi projetada para operar com quatro produtos. Ela aceita apenas pagamento em dinheiro e **não fornece troco**. A entrega do produto só ocorre após o pagamento completo.

Existem dois modos de operação:
- **Modo Cliente**: Para compra e seleção de produtos.
- **Modo Operador**: Para a reposição dos produtos no sistema.

### Interação Usuário - Máquina (Compra)

1. O cliente pressiona o botão `COMPRA`.
2. Seleciona o produto desejado com `product_select_buy`.
3. Visualiza o preço e a quantidade nos visores `price_display` e `quantity_display`.
4. Insere o dinheiro progressivamente (`money_in`).
5. Quando o valor inserido cobre o preço do produto, o cliente pressiona `PAG`.
6. A FSM ativa o motor e entrega o produto.

### Interação com Operador (Reposição)

1. O operador pressiona `REP`.
2. Seleciona o produto e insere a quantidade desejada para a reposição.
3. Pressiona `REP` novamente para confirmar a operação ou `ESQ` para sair.

---

## 📊 Máquina de Estados Finitos (FSM)

O controle do sistema é realizado por uma FSM com quatro estados principais, conforme detalhado no diagrama da Figura 1 do documento de especificação.

### Estados da FSM

- **Wait**
  - Estado inicial que aguarda uma ação do cliente ou operador.
  - Transição para `Seleção_C` ao receber o sinal `COMPRA`.
  - Transição para `Seleção_R` ao receber o sinal `REP`.

- **Seleção_C (Compra)**
  - Neste estado, o preço e a quantidade do produto escolhido são exibidos.
  - Permite uma nova seleção (`SELECT_C`), o cancelamento da compra (`ESC`) ou a realização do pagamento (`PAG`) se houver produto disponível.

- **Seleção_R (Reposição)**
  - Permite ao operador selecionar um produto e definir a quantidade a ser reposta.
  - O comando `REP` confirma a nova quantidade.
  - O comando `ESQ` faz o sistema retornar ao estado inicial (`Wait`).

- **Entrega**
  - Neste estado, o produto é entregue, ativando o sinal `motor_enable` por um ciclo.
  - Após a entrega, o sistema retorna automaticamente ao estado `Wait`.

---

## 🔌 Entradas e Saídas do Sistema

### Entradas do Sistema

| Sinal                    | Tipo               | Tamanho | Descrição                                |
|--------------------------|--------------------|---------|--------------------------------------------|
| `clk`                    | `std_logic`        | 1 bit   | Clock de 1 Hz.                             |
| `reset`                  | `std_logic`        | 1 bit   | Reset síncrono da FSM.                     |
| `money_in`               | `integer`          | 8 bits  | Valor em dinheiro inserido.                |
| `product_select_buy`     | `std_logic_vector` | 3 bits  | Seleção de produto pelo cliente.           |
| `product_select_replenish` | `std_logic_vector` | 3 bits  | Seleção de produto pelo operador.          |
| `replenish_quantity`     | `integer`          | 8 bits  | Quantidade a ser adicionada na reposição.  |
| `COMPRA`                 | `std_logic`        | 1 bit   | Inicia o processo de compra.               |
| `SELECT_C`               | `std_logic`        | 1 bit   | Confirma a seleção do produto.             |
| `PAG`                    | `std_logic`        | 1 bit   | Confirma o pagamento.                      |
| `REP`                    | `std_logic`        | 1 bit   | Inicia ou confirma a reposição.            |
| `ESC`                    | `std_logic`        | 1 bit   | Cancela a compra.                          |
| `ESQ`                    | `std_logic`        | 1 bit   | Sai de qualquer processo atual.            |
| `QTD`                    | `std_logic`        | 1 bit   | Indica que há produto disponível.          |
| `RS`                     | `std_logic`        | 1 bit   | Indica que a reposição foi bem-sucedida.   |

### Saídas do Sistema

| Sinal             | Tipo      | Tamanho | Descrição                          |
|-------------------|-----------|---------|--------------------------------------|
| `quantity_display`| `integer` | 8 bits  | Mostra a quantidade do produto atual. |
| `price_display`   | `integer` | 8 bits  | Mostra o preço do produto atual.      |
| `motor_enable`    | `std_logic` | 1 bit | Ativa o motor de entrega.             |

---

## 💾 Registradores Internos

| Nome                   | Tipo       | Tamanho   | Função                                     |
|------------------------|------------|-----------|---------------------------------------------|
| `state`                | `enum`     | 2 bits    | Armazena o estado atual da FSM.             |
| `produto_sel_comprado` | `integer`  | 2 bits    | Índice do produto selecionado pelo cliente. |
| `produto_sel_repor`    | `integer`  | 2 bits    | Índice do produto selecionado para reposição. |
| `preco[0..3]`          | `integer array` | 4x8 bits | Vetor de preços dos produtos.               |
| `quantidade[0..3]`     | `integer array` | 4x8 bits | Vetor de quantidades dos produtos.          |
| `valor_acumulado`      | `integer`  | 8 bits    | Armazena o valor inserido pelo cliente.     |
| `entrega_efetuada`     | `std_logic`| 1 bit     | Indica que a entrega ocorreu.               |

---

## 📝 Observações Finais

- O sistema **não devolve troco**.
- Os preços devem ser múltiplos inteiros da menor moeda permitida.
- O clock de 1 Hz simplifica o controle e a contagem de ciclos para ações temporizadas.
- A estrutura trabalha com **4 produtos fixos**, definidos em vetores de tamanho 4.
