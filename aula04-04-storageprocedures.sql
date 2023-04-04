DO $$
DECLARE
	valor1 INT := 2;
	valor2 INT := 3;
BEGIN
	CALL sp_acha_maior(valor1, valor2);
	RAISE NOTICE '% é o maior',valor1;
END;
$$



DROP PROCEDURE IF EXISTS sp_acha_maior;

CREATE OR REPLACE PROCEDURE sp_acha_maior
(INOUT p_valor1 INT, IN p_valor2 INT)
LANGUAGE plpgsql
AS $$
BEGIN
	IF p_valor2 > p_valor1 THEN
		p_valor1 := p_valor2;
	END IF;
END;
$$

CREATE OR REPLACE PROCEDURE sp_acha_maior
(OUT p_resultado INT, IN p_valor1 INT, IN p_valor2 INT)
LANGUAGE plpgsql
AS $$
BEGIN
	CASE 
		WHEN p_valor1 > p_valor2 THEN
			$1 := p_valor1;
		ELSE
			p_resultado := p_valor2;
	END CASE;
END; 
$$

DO $$ 
DECLARE
	resultado INT;
BEGIN
	CALL sp_acha_maior (resultado, 2, 3);
	RAISE NOTICE '% é o maior', resultado;
END;
$$


DROP PROCEDURE IF EXISTS sp_acha_maior;

CALL sp_acha_maior(2, 3);

CREATE OR REPLACE PROCEDURE sp_acha_maior
(IN p_valor1 INT, p_valor2 INT)
LANGUAGE plpgsql
AS $$
BEGIN
	IF p_valor1 > p_valor2 THEN
		RAISE NOTICE '% é o maior', $1;
	ELSE
		RAISE NOTICE '% é o maior', $2;
	END IF;
END;
$$



CALL sp_ola_usuario('Pedro');

--CRIANDO 
CREATE OR REPLACE PROCEDURE sp_ola_usuario
(nome VARCHAR(200))
LANGUAGE plpgsql
as $$
BEGIN
--ACESSANDO O PARÂMETRO PELO NOME
	RAISE NOTICE 'olá, %', nome;	
--ASSIM TAMBÉM É POSSÍVEL 
	RAISE NOTICE 'olá, %', $1; -- ASSIM É O PRIMEIRO PELA ESQUERDA
	
END;
$$



--CRIAR O PROCEDIMENTO
CREATE OR REPLACE PROCEDURE sp_ola_procedures()
LANGUAGE plpgsql
AS $$
BEGIN
	RAISE NOTICE 'Olá, procedures';
END;
$$


--CHAMAR (COLOCAR EM EXECUÇÃO)
CALL sp_ola_procedures();
