# Controlador de Máquina de Vendas – FSM em VHDL

## 📌 Descrição Geral

Este projeto consiste em uma **Máquina de Estados Finitos (FSM)** escrita em **VHDL** e sintetizável em **nível RTL**, responsável por controlar uma **máquina de vendas automática**, com funcionalidades de compra, exibição de informações e reposição de produtos.

---

## ✅ Requisitos Funcionais

### Estrutura da Máquina

* A máquina de vendas opera inicialmente com **4 produtos distintos**.
* O design deve ser **escalável**, permitindo a adição de mais produtos com adaptações mínimas.

### Lógica de Vendas

* Permitir a **seleção de um produto**.
* Ao selecionar o produto, **exibir o preço e a quantidade disponível**.
* Aceitar **apenas pagamento em dinheiro**.
* **Não há devolução de troco** — os preços são ajustados para refletir essa limitação, com informação clara ao usuário.
* A **entrega do produto ocorre apenas após o pagamento integral**.

---

## 🧽 Sensores e Entradas

* **Recebimento de Pagamentos**: sensores detectam a quantia inserida.
* **Seleção de Produtos (Compra)**: teclado com 4 dígitos para escolha do produto pelo cliente.
* **Seleção de Produtos (Reposição)**: teclado interno (acesso restrito) para escolha do produto e da quantidade a repor.

---

## 🔋 Saídas

* **Quantidade**: exibição do número de unidades disponíveis (reposição - vendas).
* **Preço**: exibição do valor do produto selecionado.
* **Motor**: sinal de `Enable` ativa o mecanismo de entrega.

---

## ❌ Restrições Não Funcionais

* A lógica deve ser implementada como uma **FSM em RTL**, de **alto nível** e **sintetizável**.
* **Não utilizar `wait` nem `delay`** — todo controle de tempo deve ser feito com **contadores de ciclos de clock**.
* O clock de entrada é assumido como **1 Hz**, para simplificação.

---

## 🔌 Requisitos de Interface

### Entradas

| Sinal                      | Descrição                                                |
| -------------------------- | -------------------------------------------------------- |
| `clk`                      | Clock de entrada (1 Hz)                                  |
| `reset`                    | Reset geral da máquina                                   |
| `money_in`                 | Representa o valor em dinheiro inserido                  |
| `product_select_buy`       | Seleção de produto para compra (4 bits)                  |
| `product_select_replenish` | Seleção de produto para reposição (interno)              |
| `replenish_quantity`       | Quantidade de unidades a serem repostas                  |
| `COMPRA`                   | Inicia o processo de compra                              |
| `SELECT_C`                 | Confirma seleção de produto para compra                  |
| `PAG`                      | Indica que o pagamento foi concluído                     |
| `REP`                      | Inicia ou confirma reposição                             |
| `ESC`                      | Retorna ao estado inicial (cancelar seleção de compra)   |
| `ESQ`                      | Retorna ao estado inicial após entrega ou reposição      |
| `QTD = 1`                  | Indica que há pelo menos 1 unidade do produto disponível |
| `RS = 1`                   | Indica que a reposição foi bem-sucedida                  |

### Saídas

| Sinal              | Descrição                                            |
| ------------------ | ---------------------------------------------------- |
| `quantity_display` | Exibe a quantidade disponível do produto selecionado |
| `price_display`    | Exibe o preço do produto selecionado                 |
| `motor_enable`     | Ativa o mecanismo de entrega do produto              |

---

## 🔄 Estados da FSM

### 1. `Wait`

* Estado inicial.
* Espera interação do usuário.
* Transições:

  * `COMPRA` → `Seleção_C`
  * `REP` → `Seleção_R`

### 2. `Seleção_C` (Compra)

* O usuário escolhe o produto.
* Exibe preço e quantidade disponíveis.
* Transições:

  * `SELECT_C` → loop interno (permite nova seleção)
  * `PAG` (com `QTD = 1`) → `Entrega`
  * `ESC` → `Wait`

### 3. `Seleção_R` (Reposição)

* O operador seleciona o produto e a quantidade a repor.
* Transições:

  * `REP` → loop interno (nova reposição)
  * `ESQ` → `Wait`

### 4. `Entrega`

* A máquina entrega o produto.
* Ativa `motor_enable`.
* Transição:

  * Após entrega → `Wait`

---

## 📁 Estrutura de Arquivos (sugestão)

```
├── src/
│   ├── vending_fsm.vhd
│   ├── product_register.vhd
│   ├── display_controller.vhd
│   └── ...
├── testbench/
│   └── vending_tb.vhd
├── README.md
└── synthesis/
    └── (arquivos de síntese e mapas de pinos)
```

---

## 🧪 Uso

### Compra de Produto

1. Pressione `COMPRA`
2. Selecione o produto com `product_select_buy`
3. Visualize `price_display` e `quantity_display`
4. Insira dinheiro (`money_in`) até atingir o valor total
5. Pressione `PAG` para realizar a entrega

### Reposição de Produto (uso interno)

1. Pressione `REP`
2. Selecione o produto com `product_select_replenish`
3. Insira `replenish_quantity`
4. Pressione `REP` para confirmar ou `ESQ` para sair
