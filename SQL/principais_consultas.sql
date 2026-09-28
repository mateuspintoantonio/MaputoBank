-- ============================================================
-- PROJECTO MAPUTOBANK
-- PRINCIPAIS CONSULTAS SQL
-- ============================================================
--
-- Base de dados: MAPUTOBANK
-- SGBD: POSTGRESQL
--
-- Objectivo:
-- Analisar clientes, contas, transacções financeiras e
-- desempenho das agências.
-- ============================================================


-- ============================================================
-- 1. TOTAL DE CLIENTES
-- ============================================================
-- Pergunta:
-- Quantos clientes existem no MaputoBank?

SELECT
    COUNT(*) AS TOTAL_CLIENTES
FROM DIM_CLIENTES;


-- ============================================================
-- 2. CLIENTES COM E SEM CONTA
-- ============================================================
-- Pergunta:
-- Quantos clientes possuem conta e quantos não possuem?

SELECT
    CASE
        WHEN CT.ID_CONTA IS NULL THEN 'SEM CONTA'
        ELSE 'COM CONTA'
    END AS SITUACAO,
    COUNT(DISTINCT C.ID_CLIENTE) AS QUANTIDADE_CLIENTES
FROM DIM_CLIENTES C
LEFT JOIN DIM_CONTAS CT
    ON C.ID_CLIENTE = CT.ID_CLIENTE
GROUP BY
    CASE
        WHEN CT.ID_CONTA IS NULL THEN 'SEM CONTA'
        ELSE 'COM CONTA'
    END
ORDER BY QUANTIDADE_CLIENTES DESC;


-- ============================================================
-- 3. DISTRIBUIÇÃO DAS CONTAS POR ESTADO
-- ============================================================
-- Pergunta:
-- Como estão distribuídas as contas entre Activo, Inactivo
-- e Bloqueado?

SELECT
    STATUS,
    COUNT(*) AS QUANTIDADE_CONTAS
FROM DIM_CONTAS
GROUP BY STATUS
ORDER BY QUANTIDADE_CONTAS DESC;


-- ============================================================
-- 4. TRANSAÇÕES POR TIPO
-- ============================================================
-- Pergunta:
-- Qual é o tipo de transação mais utilizado?

SELECT
    TT.NOME_TIPO_TRANSACAO,
    COUNT(T.ID_TRANSACAO) AS QUANTIDADE_TRANSACOES
FROM FATO_TRANSACOES T
INNER JOIN DIM_TIPO_TRANSACOES TT
    ON T.ID_TIPO_TRANSACAO = TT.ID_TIPO_TRANSACAO
GROUP BY TT.NOME_TIPO_TRANSACAO
ORDER BY QUANTIDADE_TRANSACOES DESC;


-- ============================================================
-- 5. VALOR MOVIMENTADO POR TIPO DE TRANSAÇÃO
-- ============================================================
-- Pergunta:
-- Qual é o valor financeiro movimentado por cada tipo
-- de transação?

SELECT
    TT.NOME_TIPO_TRANSACAO,
    COUNT(T.ID_TRANSACAO) AS QUANTIDADE_TRANSACOES,
    SUM(T.VALOR) AS VALOR_TOTAL_MOVIMENTADO
FROM FATO_TRANSACOES T
INNER JOIN DIM_TIPO_TRANSACOES TT
    ON T.ID_TIPO_TRANSACAO = TT.ID_TIPO_TRANSACAO
GROUP BY TT.NOME_TIPO_TRANSACAO
ORDER BY VALOR_TOTAL_MOVIMENTADO DESC;


-- ============================================================
-- 6. EVOLUÇÃO DO VALOR MOVIMENTADO POR ANO
-- ============================================================
-- Pergunta:
-- Como evoluiu o valor movimentado ao longo dos anos?

SELECT
    EXTRACT(YEAR FROM DATA_TRANSACAO) AS ANO,
    SUM(VALOR) AS VALOR_MOVIMENTADO
FROM FATO_TRANSACOES
GROUP BY EXTRACT(YEAR FROM DATA_TRANSACAO)
ORDER BY ANO;


-- ============================================================
-- 7. DESEMPENHO DAS AGÊNCIAS
-- ============================================================
-- Pergunta:
-- Como se comparam as agências em termos de clientes,
-- contas, transações e valor movimentado?

SELECT
    A.NOME_AGENCIA,
    COUNT(DISTINCT CT.ID_CLIENTE) AS CLIENTES,
    COUNT(DISTINCT CT.ID_CONTA) AS CONTAS,
    COUNT(DISTINCT T.ID_TRANSACAO) AS TRANSACOES,
    COALESCE(SUM(T.VALOR), 0) AS VALOR_MOVIMENTADO
FROM DIM_AGENCIAS A
LEFT JOIN DIM_CONTAS CT
    ON A.ID_AGENCIA = CT.ID_AGENCIA
LEFT JOIN FATO_TRANSACOES T
    ON CT.ID_CONTA = T.ID_CONTA
GROUP BY A.NOME_AGENCIA
ORDER BY VALOR_MOVIMENTADO DESC;


-- ============================================================
-- 8. NÚMERO DE CONTAS POR CLIENTE
-- ============================================================
-- Pergunta:
-- Quantas contas possui cada cliente?

SELECT
    C.ID_CLIENTE,
    C.NOME,
    COUNT(CT.ID_CONTA) AS NUMERO_CONTAS
FROM DIM_CLIENTES C
LEFT JOIN DIM_CONTAS CT
    ON C.ID_CLIENTE = CT.ID_CLIENTE
GROUP BY
    C.ID_CLIENTE,
    C.NOME
ORDER BY NUMERO_CONTAS DESC;


-- ============================================================
-- 9. TOP 10 CLIENTES POR NÚMERO DE TRANSAÇÕES
-- ============================================================
-- Pergunta:
-- Quais clientes apresentam o maior número de transações?

SELECT
    C.NOME,
    COUNT(T.ID_TRANSACAO) AS NUMERO_TRANSACOES
FROM DIM_CLIENTES C
INNER JOIN DIM_CONTAS CT
    ON C.ID_CLIENTE = CT.ID_CLIENTE
INNER JOIN FATO_TRANSACOES T
    ON CT.ID_CONTA = T.ID_CONTA
GROUP BY
    C.ID_CLIENTE,
    C.NOME
ORDER BY NUMERO_TRANSACOES DESC
LIMIT 10;


-- ============================================================
-- 10. AUDITORIA DA QUALIDADE DOS DADOS
-- ============================================================
-- Pergunta:
-- Existem transações registadas antes da abertura das contas?

SELECT
    COUNT(*) AS TRANSACOES_ANTES_ABERTURA
FROM FATO_TRANSACOES T
INNER JOIN DIM_CONTAS CT
    ON T.ID_CONTA = CT.ID_CONTA
WHERE T.DATA_TRANSACAO < CT.DATA_ABERTURA;


-- ============================================================
-- FIM DAS PRINCIPAIS CONSULTAS
-- ============================================================