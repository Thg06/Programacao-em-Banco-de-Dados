CREATE OR REPLACE sp_obter_notas_para_compor_o_troco(
	OUT resultado varchar(500),
	IN troco INT
) LANGUAGE plpgsql AS $$
DECLARE
	nota200 INT := 0;
	notas100 INT :=0;
	notas50 INT := 0;
	notas20 INT :=0;
	notas10 INT :=0;
	notas5 INT :=0;
	notas2 INT :=0;
	moedas1 INT :=0;	
BEGIN 
	nota200 := troco / 200;
	notas100 := troco % 200 / 100;
	notas50 := troco % 100 / 50;
	notas20 := troco % 50 / 20;
	notas10 := troco % 20 / 10;
	notas5 := troco % 10 / 5;
	notas2 := troco % 5/ 2;
	moedas1 := troco % 2 / 1;
END;
$$



--ESCREVER UM BLOQUINHO ANÔNIMO
--CHAMA O PROC PARA CALCULAR O VALOR DO PEDIDO 1
DO $$
DECLARE
	troco INT;
	valor_total INT;
	valor_a_pagar INT := 100;
BEGIN 
	CALL sp_valor_de_um_pedido(1, valor_total);
	CALL sp_calcular_troco(troco, valor_a_pagar, valor_total);
	RAISE NOTICE 'Você consumiu R$% e pagou R$%. Portanto,sei troc é R$%', valor_total, valor_a_pagar, troco;
END;
$$
--CHAMA O PROC PARA CALCULARO VALOR DO TROCO QUANDO O VALOR DE PAGAMENTO É IGUAL A 100
-- POR FIM, ELE MOSTRA OTOTAL DA CONTA E O VALOR DE TROCO


CREATE OR REPLACE PROCEDURE sp_calcular_troco(
	OUT p_troco INT,
	IN p_valor_a_pagar INT,
	IN p_valor_total INT
)LANGUAGE plpgsql AS $$
BEGIN
	p_troco := p_valor_a_pagar - p_valor_total;
END;
$$
drop procedure sp_calcular_troco



DO $$
BEGIN 
	CALL sp_fechar_pedido(200, 1);
END;
$$
	


CREATE OR REPLACE PROCEDURE sp_fechar_pedido(
	IN p_valor_a_pagar INT,
	IN p_cod_pedido INT
) LANGUAGE plpgsql AS $$
DECLARE
	valor_total INT;	
BEGIN 
	CALL sp_calcular_valor_de_um_pedido(
		p_cod_pedido,
		valor_total
	);
	IF p_valor_a_pagar < valor_total THEN
		RAISE 'R$% é insuficiente para pagar a conta de R$%', p_valor_a_pagar, valor_total;
	ELSE 
		UPDATE tb_pedido p SET
			data_modificacao = 	CURRENT_TIMESTAMP,
			status = 'Fechado'
			WHERE p.cod_pedido = $2;
	END IF;
END;
$$


DO $$
DECLARE
	valor_total INT;
BEGIN
	CALL sp_calcular_valor_de_um_pedido(1, valor_total);
	RAISE NOTICE 'Total do pedido %: R$%', 1, valor_total;
END;
$$





CREATE OR REPLACE PROCEDURE sp_calcular_valor_de_um_pedido(
		IN p_cod_pedido INT,
		OUT p_valor_total INT
) LANGUAGE plpgsql AS $$
BEGIN
	SELECT 
		--p.cod_pedido, i.cod_item, i.valor 
		SUM (i.valor)
	FROM 
		tb_pedido p 
			INNER JOIN
		tb_item_pedido ip
			ON p.cod_pedido = ip.cod_pedido
			INNER JOIN
		tb_item i
			ON ip.cod_item = i.cod_item
		WHERE p.cod_pedido = p_cod_pedido
		INTO $2;
END;
$$


CALL sp_adicionar_item_a_pedido(3, 1);





--ADICIONAR UM ITEM A UM PEDIDO 
CREATE OR REPLACE PROCEDURE sp_adicionar_item_a_pedido(
	IN p_cod_item INT,
	IN p_cod_pedido INT
)
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO tb_item_pedido (cod_item, cod_pedido) VALUES (p_cod_item, p_cod_pedido);
	UPDATE tb_pedido p SET data_modificacao = CURRENT_TIMESTAMP WHERE p.cod_pedido = $2;
	
END;
$$






DO $$
DECLARE
	cod_pedido INT;
	cod_cliente INT;
BEGIN
	SELECT c.cod_cliente FROM tb_cliente c WHERE nome LIKE 'João da Silva' INTO cod_cliente;
	CALL sp_criar_pedido(cod_pedido, cod_cliente);
	RAISE NOTICE 'Código do pedido recém criado: %', cod_pedido;
END;
$$


CALL sp_cadastrar_cliente('João da Silva');
CALL sp_cadastrar_cliente('Maria Santos');


SELECT * FROM tb_cliente;


--CRIAR UM PEDIDO, COMO SE O CLIENTE ENTRASSE NO RESTAURANTE E PEGASSE A COMANDA 
CREATE OR REPLACE PROCEDURE sp_criar_pedido(
	OUT p_cod_pedido INT,
	IN p_cod_cliente INT
)	LANGUAGE plpgsql AS $$

BEGIN
	INSERT INTO tb_pedido (cod_cliente) VALUES (p_cod_cliente);
	--LASTVAL É UMA FUNÇÃO DO POSTGRES QUE OBTÉM O ÚLTIMO VALOR GERADO PELO MECANISMO SERIAL
	SELECT LASTVAL() INTO p_cod_pedido;	
END;
$$







--CADASTRO DE CLIENTE
CREATE OR REPLACE PROCEDURE sp_cadastrar_cliente(
	IN  p_nome VARCHAR(200),
	IN p_codigo INT DEFAULT NULL
)	LANGUAGE plpgsql AS $$

BEGIN 
	IF p_codigo  IS NULL THEN
		INSERT INTO tb_cliente(nome) VALUES (p_nome);	
	ELSE
		INSERT INTO tb_cliente(cod_cliente, nome) VALUES (p_codigo, p_nome);
	END IF;
END;
$$
Drop  procedure sp_cadastrar_cliente


CREATE TABLE tb_item_pedido(
	--surrogate key
	cod_item_pedido SERIAL PRIMARY KEY,
	cod_item INT,
	cod_pedido INT,
	CONSTRAINT fk_item FOREIGN KEY (cod_item) REFERENCES tb_item(cod_item),
	CONSTRAINT fk_pedido FOREIGN KEY (cod_pedido) REFERENCES tb_pedido(cod_pedido)	
);




CREATE TABLE tb_item(
	cod_item SERIAL PRIMARY KEY,
	descricao VARCHAR (200) NOT NULL,
	valor NUMERIC(10, 2) NOT NULL,
	cod_tipo INT NOT NULL,
	CONSTRAINT fk_tipo_item FOREIGN KEY (cod_tipo) REFERENCES tb_tipo_item(cod_tipo)
);

INSERT INTO tb_item (descricao, valor, cod_tipo)
VALUES
('Refrigerante', 7, 1),
('Suco', 8, 1),
('Hamburguer', 12, 2),
('Batata frita', 9, 2);





CREATE TABLE tb_tipo_item(
	cod_tipo SERIAL PRIMARY KEY,
	descricao VARCHAR(200) NOT NULL
);

INSERT INTO tb_tipo_item (descricao) VALUES ('Bebida'),('Comida');
SELECT * FROM tb_tipo_item;

CREATE TABLE tb_pedido(
	cod_pedido SERIAL PRIMARY KEY,
	data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	data_modificacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	status VARCHAR(200) DEFAULT 'aberto',
	cod_cliente INT NOT NULL,
	CONSTRAINT fk_cliente FOREIGN KEY (cod_cliente) REFERENCES tb_cliente(cod_cliente)
);


CREATE TABLE tb_cliente(
	cod_cliente SERIAL PRIMARY KEY,
	nome VARCHAR(200) NOT NULL
);