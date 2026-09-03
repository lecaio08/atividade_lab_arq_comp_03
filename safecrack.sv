module safecrack (
    input  logic clk,
    input  logic rst,
    input  logic [3:0] btn,
    output logic unlocked
);

    // 1. Lógica de Detecção de Borda
    logic [3:0] btn_prev;
    logic [3:0] pulse;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) btn_prev <= 4'b0000;
        else     btn_prev <= btn;
    end
    
    // O pulso só vai a 1 no ciclo exato em que o botão vai de 0 para 1
    assign pulse = btn & ~btn_prev;

    // 2. Definição dos Estados (Codificação One-Hot)
    typedef enum logic [4:0] {
        INIT     = 5'b00001,
        BLUE     = 5'b00010,
        YEL1     = 5'b00100,
        YEL2     = 5'b01000,
        UNLOCKED = 5'b10000
    } state_t;

    state_t state_reg, state_next;

    // 3. Registrador de Estado (Memória da FSM)
    always_ff @(posedge clk or posedge rst) begin
        if (rst) state_reg <= INIT;
        else     state_reg <= state_next;
    end

    // 4. Lógica de Próximo Estado
    always_comb begin
        state_next = state_reg; // Valor padrão: mantém o estado

        // Só avalia transição se houver algum botão pressionado
        if (pulse != 4'b0000) begin
            case (state_reg)
                INIT: begin
                    if (pulse == 4'b0001) state_next = BLUE;
                    else state_next = INIT;
                end
                BLUE: begin
                    if (pulse == 4'b0010) state_next = YEL1;
                    else state_next = INIT;
                end
                YEL1: begin
                    if (pulse == 4'b0010) state_next = YEL2;
                    else state_next = INIT;
                end
                YEL2: begin
                    if (pulse == 4'b1000) state_next = UNLOCKED;
                    else state_next = INIT;
                end
                UNLOCKED: begin
                    state_next = UNLOCKED; // Permanece desbloqueado até o reset
                end
                default: state_next = INIT;
            endcase
        end
    end

    // 5. Lógica de Saída
    assign unlocked = (state_reg == UNLOCKED) ? 1'b1 : 1'b0;

endmodule
