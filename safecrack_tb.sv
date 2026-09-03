module safecrack_tb();

    logic clk;
    logic rst;
    logic [3:0] btn;
    logic unlocked;

    // Instancia o módulo do cofre
    safecrack uut (
        .clk(clk),
        .rst(rst),
        .btn(btn),
        .unlocked(unlocked)
    );

    // Gera o Clock (período de 10 unidades de tempo)
    always #5 clk = ~clk;

    // Simulação dos eventos
    initial begin
        // Inicialização
        clk = 0;
        rst = 1;
        btn = 4'b0000;
        
        #10 rst = 0; // Desativa o reset

        // Teste 1: Sequência Correta (0001 -> 0010 -> 0010 -> 1000)
        #10 btn = 4'b0001; #10 btn = 4'b0000; // Aperta e solta Azul
        #10 btn = 4'b0010; #10 btn = 4'b0000; // Aperta e solta Amarelo
        #10 btn = 4'b0010; #10 btn = 4'b0000; // Aperta e solta Amarelo
        #10 btn = 4'b1000; #10 btn = 4'b0000; // Aperta e solta Vermelho
        
        #20 rst = 1; #10 rst = 0; // Reseta o cofre para o próximo teste

        // Teste 2: Sequência Errada (0001 -> 0100 - Erro!)
        #10 btn = 4'b0001; #10 btn = 4'b0000; 
        #10 btn = 4'b0100; #10 btn = 4'b0000; 

        #50 $finish; // Encerra a simulação
    end

endmodule
