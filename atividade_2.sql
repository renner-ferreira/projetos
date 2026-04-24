-- 1. Adicione mais campos à tabela Pessoa: RG, CPF, Data de nascimento
ALTER TABLE Pessoa ADD COLUMN RG VARCHAR(20);
ALTER TABLE Pessoa ADD COLUMN CPF VARCHAR(14);
ALTER TABLE Pessoa ADD COLUMN DataNascimento DATE;

-- 2. Altere as pessoas que já estão inseridas colocando seus respectivos RG e CPF
UPDATE Pessoa SET RG = '123456789', CPF = '111.111.111-11', DataNascimento = '1990-05-15' WHERE Codigo = 1;
UPDATE Pessoa SET RG = '987654321', CPF = '222.222.222-22', DataNascimento = '1988-11-20' WHERE Codigo = 2;
UPDATE Pessoa SET RG = '112233445', CPF = '333.333.333-33', DataNascimento = '1995-03-10' WHERE Codigo = 3;
UPDATE Pessoa SET RG = '554433221', CPF = '444.444.444-44', DataNascimento = '2002-07-25' WHERE Codigo = 4;
UPDATE Pessoa SET RG = '998877665', CPF = '555.555.555-55', DataNascimento = '1985-01-01' WHERE Codigo = 5;

-- Inserir mais alguns dados para testes futuros, incluindo uma pessoa com 14 anos e uma com RG começando com 55
INSERT INTO Pessoa (Nome, Ativo, Sexo, RG, CPF, DataNascimento) VALUES
('Mariana Costa', TRUE, 'F', '551234567', '666.666.666-66', '2010-04-01'),
('Fernando Lima', TRUE, 'M', '109876543', '777.777.777-77', '1999-09-30'),
('Marcos Antunes', TRUE, 'M', '234567890', '888.888.888-88', '1980-12-05');

-- 3. Faça um select mostrando todas as pessoas com seus dados.
SELECT * FROM Pessoa;

-- 4. Faça um select mostrando todas as pessoas com seus dados e seus respectivos telefones.
SELECT
    P.Codigo, P.Nome, P.Ativo, P.Sexo, P.RG, P.CPF, P.DataNascimento,
    TP.DDD, TP.Numero
FROM
    Pessoa AS P
LEFT JOIN
    Telefone_Pessoa AS TP ON P.Codigo = TP.Codigo_Pessoa;

-- 5. Faça um select mostrando todas as pessoas com seus dados que tenham 14 anos;
-- Considerando a data atual como 2026-04-23 para cálculo de idade.
SELECT * FROM Pessoa WHERE strftime('%Y', 'now') - strftime('%Y', DataNascimento) = 14;

-- 6. Faça um select mostrando todas as pessoas com seus dados em que sua data de nascimento seja maior que 01/05/2000
SELECT * FROM Pessoa WHERE DataNascimento > '2000-05-01';

-- 7. Faça um select mostrando todas as pessoas com seus dados onde seus RG comecem com 55
SELECT * FROM Pessoa WHERE RG LIKE '55%';

-- 8. Faça um select mostrando todas as pessoas com seus onde seus nomes comecem com MAR
SELECT * FROM Pessoa WHERE Nome LIKE 'Mar%';
