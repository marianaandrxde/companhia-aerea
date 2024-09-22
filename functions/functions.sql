
/*
 ========================================
 ||                                    ||
 ||       Função para CADASTRAR        ||
 ||                                    ||
 ========================================
 */

CREATE OR REPLACE FUNCTION CADASTRAR(
    P_TABELA TEXT,
    P_CAMPOS TEXT,
    P_VALORES TEXT
) RETURNS TEXT AS $$
BEGIN
    EXECUTE format('INSERT INTO %I (%s) VALUES (%s)', P_TABELA, P_CAMPOS, P_VALORES);
    RETURN 'Dados cadastrados com sucesso em ' || P_TABELA;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Erro ao cadastrar dados em ' || P_TABELA || ': ' || SQLERRM;
END;
$$ LANGUAGE PLPGSQL;

--==============================================================================================
--SELECT cadastrar('usuario', 'CPF, NOME, DT_NASC, EMAIL, ENDERECO, TELEFONE', '''12345678901'',
--''MARIANA'', ''2005-04-13'',''mariana@gmail.com'',''casa das flores'', ''86912345678''');
--==============================================================================================

/*
 ========================================
 ||                                    ||
 ||       Função para ATUALIZAR        ||
 ||                                    ||
 ========================================
 */
 
CREATE OR REPLACE FUNCTION ATUALIZAR(
    P_TABELA TEXT,
    P_CAMPO_VALOR TEXT,
    P_CHAVE TEXT
) RETURNS TEXT AS $$
DECLARE
    V_LINHAS_AFETADAS INT;
BEGIN
    EXECUTE format('UPDATE %I SET %s WHERE %s', P_TABELA, P_CAMPO_VALOR, P_CHAVE);
    
    GET DIAGNOSTICS V_LINHAS_AFETADAS = ROW_COUNT;

    IF v_linhas_afetadas = 0 THEN
        RETURN 'ERRO: Nenhum dado de ' || P_TABELA || ' possui a chave ' || P_CHAVE;
    ELSE
        RETURN 'Dados atualizados com sucesso em ' || P_TABELA;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Erro ao atualizar dados em ' || P_TABELA || ': ' || SQLERRM;
END;
$$ LANGUAGE PLPGSQL;

--==============================================================================================
--SELECT ATUALIZAR('classe', 'DESCRICAO = ''Classe executiva com mais conforto e'',
--VALOR = ''1099.99''', 'ID_CLASSE = 1');
--==============================================================================================

/*
 ========================================
 ||                                    ||
 ||       Função para DELETAR          ||
 ||                                    ||
 ========================================
 */

CREATE OR REPLACE FUNCTION DELETAR(
    P_TABELA TEXT,
    P_CHAVE TEXT
) RETURNS TEXT AS $$
DECLARE V_LINHAS_AFETADAS INT;
BEGIN
    EXECUTE format('DELETE FROM %I WHERE %s', P_TABELA, P_CHAVE);

    GET DIAGNOSTICS V_LINHAS_AFETADAS = ROW_COUNT;

    IF V_LINHAS_AFETADAS = 0 THEN
        RETURN 'ERRO: Nenhum dado de ' || P_TABELA || ' possui a chave ' || P_CHAVE;
    ELSE
        RETURN 'Dados removidos com sucesso de ' || P_TABELA;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Erro ao remover dados de ' || P_TABELA || ': ' || SQLERRM;
END;
$$ LANGUAGE PLPGSQL;

--==============================================================================================
--SELECT DELETAR('classe', 'ID_CLASSE = 1');
--==============================================================================================


-- Funções
/*
 ========================================
 ||                                    ||
 ||      Função para Validar CPF       ||
 ||                                    ||
 ========================================
 */
 
CREATE OR REPLACE FUNCTION VALIDAR_CPF(CPF VARCHAR(11)) 
RETURNS VOID AS $$
DECLARE CPF_ARRAY INT [] := STRING_TO_ARRAY(CPF, NULL);
SOMA_DIGITO_1 INT := 0;
SOMA_DIGITO_2 INT := 0;
BEGIN 
	IF LENGTH(CPF) != 11 THEN RAISE EXCEPTION 'CPF INVÁLIDO!';
	END IF;

	FOR INDICE IN 1..9 LOOP SOMA_DIGITO_1 := SOMA_DIGITO_1 + CPF_ARRAY [INDICE] * (11 - INDICE);
	END LOOP;

	SOMA_DIGITO_1 := 11 - (SOMA_DIGITO_1 % 11);
	IF SOMA_DIGITO_1 > 9 THEN SOMA_DIGITO_1 := 0;
	END IF;

	FOR INDICE IN 1..10 LOOP SOMA_DIGITO_2 := SOMA_DIGITO_2 + CPF_ARRAY [INDICE] * (12 - INDICE);
	END LOOP;

	SOMA_DIGITO_2 := 11 - (SOMA_DIGITO_2 % 11);

	IF SOMA_DIGITO_2 > 9 THEN SOMA_DIGITO_2 = 0;
	END IF;

	IF SOMA_DIGITO_1 != CPF_ARRAY [10]
	OR SOMA_DIGITO_2 != CPF_ARRAY [11] THEN RAISE EXCEPTION 'CPF INVÁLIDO. DÍGITOS VERIFICADORES INVÁLIDOS!';
	END IF;
	RAISE LOG 'CPF VÁLIDO!';
	END;
$$ LANGUAGE PLPGSQL;

/*
 ============================================
 ||                                    	  ||
 ||      Função para Validar TELEFONE      ||
 ||                                        ||
 ============================================
 */

CREATE OR REPLACE FUNCTION VALIDAR_TELEFONE(_TELEFONE VARCHAR(11)) 
RETURNS VOID AS $$
BEGIN
    IF LENGTH(_TELEFONE) != 11 THEN RAISE EXCEPTION 'NUMERO DE TELEFONE INVÁLIDO';
END IF;
END;
$$ LANGUAGE PLPGSQL;

/*
 =========================================
 ||                                     ||
 ||      Função para Validar EMAIL      ||
 ||                                     ||
 =========================================
 */
 
CREATE OR REPLACE FUNCTION VALIDAR_EMAIL(_EMAIL VARCHAR(100)) 
RETURNS VOID AS $$
BEGIN 
    IF NOT _EMAIL ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$' THEN RAISE EXCEPTION 'EMAIL INVALIDO. %',
_EMAIL;
END IF;
END;
$$ LANGUAGE PLPGSQL;

/*
 ========================================
 ||                                    ||
 ||    Função para Validar Reserva     ||
 ||                                    ||
 ========================================
 */

CREATE OR REPLACE FUNCTION PRIVATE_VERIFICAR_RESERVA(_ID_RESERVA INT) RETURNS VOID AS $$
	BEGIN
		IF NOT EXISTS (SELECT * FROM RESERVA WHERE ID_RESERVA = _ID_RESERVA) THEN
			RAISE EXCEPTION 'RESERVA NÚMERO % NÃO EXISTE', _ID_RESERVA;
		END IF;
	END;
$$ LANGUAGE 'plpgsql';

/*
 ========================================
 ||                                    ||
 ||   Função para Verificar Pagamento  ||
 ||                                    ||
 ========================================
 */

CREATE OR REPLACE FUNCTION PRIVATE_VERIFICAR_STATUS_DO_PAGAMENTO(_ID_RESERVA INT) 
RETURNS VOID AS $$
	BEGIN
		IF ((SELECT PAGO FROM RESERVA WHERE ID_RESERVA = _ID_RESERVA) = TRUE) THEN
			RAISE EXCEPTION 'NÃO É POSSÍVEL ADICIONAR PASSAGENS À RESERVA, POIS O PAGAMENTO FOI EFETUADO';
		END IF;
	END;
$$ LANGUAGE 'plpgsql';

/*
 ========================================
 ||                                    ||
 ||    Função para Validar ASSENTO     ||
 ||                                    ||
 ========================================
 */

CREATE OR REPLACE FUNCTION PRIVATE_VERIFICAR_ASSENTO(_ID_ASSENTO INT, _ID_VOO INT, _ID_AVIAO INT) 
RETURNS VOID AS $$
	BEGIN
		IF NOT EXISTS (SELECT * FROM AVIAO_ASSENTO_CLASSE_VOO WHERE ID_AVIAO_ASSENTO_CLASSE_VOO = _ID_ASSENTO) THEN
			RAISE EXCEPTION 'ASSENTO NÚMERO % NÃO EXISTE', _ID_ASSENTO;
		END IF;

	    IF NOT EXISTS (SELECT 1 FROM VOO V 
	                   JOIN AVIAO_ASSENTO_CLASSE_VOO AAC ON AAC.ID_VOO = V.ID_VOO 
	                   WHERE V.ID_VOO = _ID_VOO AND AAC.ID_AVIAO_ASSENTO_CLASSE_VOO = _ID_ASSENTO) THEN 
	        RAISE EXCEPTION 'NÃO É POSSÍVEL SE ASSOCIAR A UM ASSENTO DE UM OUTRO VOO';
	    END IF;
	
	    IF NOT EXISTS (SELECT 1 FROM AVIAO_ASSENTO_CLASSE_VOO 
	                   WHERE ID_AVIAO_ASSENTO_CLASSE_VOO = _ID_ASSENTO AND ID_AVIAO = _ID_AVIAO) THEN
	        RAISE EXCEPTION 'NÃO É POSSÍVEL SE ASSOCIAR A UM ASSENTO DE UM AVIÃO DIFERENTE DO ESCALADO PARA ESSE VOO';
	    END IF;
	END;
$$ LANGUAGE 'plpgsql';

/*
 ========================================
 ||                                    ||
 ||  Função para Verificar Poltrona    ||
 ||                                    ||
 ========================================
 */

CREATE OR REPLACE FUNCTION PRIVATE_VERIFICAR_POLTRONA(_ID_POLTRONA INT) RETURNS VOID AS $$
	BEGIN
		IF NOT EXISTS (SELECT * FROM ASSENTO WHERE ID_ASSENTO = _ID_POLTRONA) THEN
			RAISE EXCEPTION 'POLTRONA NÚMERO % NÃO EXISTE', _ID_POLTRONA;
		END IF;
	END;
$$ LANGUAGE 'plpgsql';

/*
 ========================================
 ||                                    ||
 ||      Função para Validar Voo       ||
 ||                                    ||
 ========================================
 */

CREATE OR REPLACE FUNCTION PRIVATE_VERIFICAR_VOO(_ID_VOO INT) RETURNS VOID AS $$
	BEGIN
		IF NOT EXISTS (SELECT * FROM VOO WHERE ID_VOO = _ID_VOO) THEN
			RAISE EXCEPTION 'VOO NÚMERO % NÃO EXISTE', _ID_VOO;
		END IF;
	END;
$$ LANGUAGE 'plpgsql';

/*
 ========================================
 ||                                    ||
 ||    Função para Validar Usuario     ||
 ||                                    ||
 ========================================
 */

CREATE OR REPLACE FUNCTION PRIVATE_VERIFICAR_USUARIO(_ID_USUARIO INT) RETURNS VOID AS $$
	BEGIN
		IF NOT EXISTS (SELECT * FROM USUARIO WHERE ID_USUARIO = _ID_USUARIO) THEN
			RAISE EXCEPTION 'USUARIO NÚMERO % NÃO EXISTE', _ID_USUARIO;
		END IF;

		IF ((SELECT ATIVO FROM USUARIO WHERE ID_USUARIO = _ID_USUARIO) = FALSE) THEN
			RAISE EXCEPTION 'USUARIO INATIVO';
		END IF;
	END;
$$ LANGUAGE 'plpgsql';

/*
 ========================================
 ||                                    ||
 ||    Função para Validar Aviao       ||
 ||                                    ||
 ========================================
 */

CREATE OR REPLACE FUNCTION PRIVATE_VERIFICAR_AVIAO(_ID_AVIAO INT) RETURNS VOID AS $$
	DECLARE STATUS BOOLEAN;
	BEGIN
		IF NOT EXISTS (SELECT * FROM AVIAO WHERE ID_AVIAO = _ID_AVIAO) THEN
			RAISE EXCEPTION 'AVIAO NÚMERO % NÃO EXISTE', _ID_AVIAO;
		END IF;

		SELECT ATIVO INTO STATUS 
		FROM AVIAO WHERE ID_AVIAO = _ID_AVIAO;

		IF(STATUS = FALSE) THEN
			RAISE EXCEPTION 'AVIAO EM REVISÃO';
		END IF;
	END;
$$ LANGUAGE 'plpgsql';

/*
 ========================================
 ||                                    ||
 ||     Função para Validar Classe     ||
 ||                                    ||
 ========================================
 */

CREATE OR REPLACE FUNCTION PRIVATE_VERIFICAR_CLASSE(_ID_CLASSE INT) RETURNS VOID AS $$
	BEGIN
		IF NOT EXISTS (SELECT * FROM CLASSE WHERE ID_CLASSE = _ID_CLASSE) THEN
			RAISE EXCEPTION 'CLASSE NÚMERO % NÃO EXISTE', _ID_CLASSE;
		END IF;
	END;
$$ LANGUAGE 'plpgsql';

/*
 ========================================
 ||                                    ||
 ||     Função para Validar Cidade     ||
 ||                                    ||
 ========================================
 */

CREATE OR REPLACE FUNCTION PRIVATE_VERIFICAR_CIDADE(_ID_CIDADE INT) RETURNS VOID AS $$
	BEGIN
		IF NOT EXISTS (SELECT * FROM CIDADE WHERE ID_CIDADE = _ID_CIDADE) THEN
			RAISE EXCEPTION 'CIDADE NÚMERO % NÃO EXISTE', _ID_CIDADE;
		END IF;
	END;
$$ LANGUAGE 'plpgsql';

/*
 ========================================
 ||                                    ||
 ||     Função para Validar Trajeto    ||
 ||                                    ||
 ========================================
 */

CREATE OR REPLACE FUNCTION PRIVATE_VERIFICAR_TRAJETO(_ID_TRAJETO INT) 
RETURNS VOID AS $$
DECLARE STATUS BOOLEAN;
	BEGIN
		IF NOT EXISTS (SELECT * FROM TRAJETO WHERE ID_TRAJETO = _ID_TRAJETO) THEN
			RAISE EXCEPTION 'TRAJETO NÚMERO % NÃO EXISTE', _ID_TRAJETO;
		END IF;
		
		SELECT ATIVO INTO STATUS 
		FROM TRAJETO WHERE ID_TRAJETO = _ID_TRAJETO;

		IF(STATUS = FALSE) THEN
			RAISE EXCEPTION 'TRAJETO ESTÁ DESATIVADO';
		END IF;
	END;
$$ LANGUAGE 'plpgsql';