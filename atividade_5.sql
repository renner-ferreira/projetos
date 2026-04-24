PRAGMA foreign_keys = ON;

-- 1. Cria uma tabela chamada PESSOA (no seu banco de teste), adicione os campos CODIGO como Inteiro e NOME como varchar de 80.
-- A tabela Pessoa já foi criada nas atividades anteriores. Vamos apenas garantir que ela está no estado correto para esta atividade.
-- Se a tabela não existisse, o comando seria:
-- CREATE TABLE PESSOA (
--     CODIGO INTEGER PRIMARY KEY AUTOINCREMENT,
--     NOME VARCHAR(80)
-- );

-- Limpar a tabela Pessoa e Telefone_Pessoa para garantir um estado limpo para a Atividade 5, se necessário.
-- DELETE FROM Telefone_Pessoa;
-- DELETE FROM Pessoa;
-- DELETE FROM Carro;
-- DELETE FROM Domicilio;
-- DELETE FROM Logradouro;
-- DELETE FROM Tipo_Logradouro;
-- DELETE FROM Bairro;
-- DELETE FROM Municipio;
-- DELETE FROM Estado;

-- Reinserir dados básicos para a Atividade 5, considerando que as tabelas de Atividade 1-4 já foram criadas e populadas.
-- Para esta atividade, vamos focar nos dados da tabela PESSOA.

-- Inserir os registros solicitados e mais 8 para a tabela PESSOA.
-- Assumindo que a tabela Pessoa já existe com as colunas Codigo, Nome, Ativo, Sexo, RG, CPF, DataNascimento, Codigo_Domicilio

-- Inserir os dois nomes fornecidos
INSERT INTO Pessoa (Nome, Ativo, Sexo, RG, CPF, DataNascimento, Codigo_Domicilio) VALUES
("AGUINALDO SUPERVISOR FERNANDO MENDES SILVA SOUZA", TRUE, "M", "111111111", "111.111.111-11", "1980-01-01", NULL),
("GUSTAVO PEREIRA DA COSTA", TRUE, "M", "222222222", "222.222.222-22", "1990-02-02", NULL);

-- Inserir mais 8 registros
INSERT INTO Pessoa (Nome, Ativo, Sexo, RG, CPF, DataNascimento, Codigo_Domicilio) VALUES
("MARIA APARECIDA DA SILVA", TRUE, "F", "333333333", "333.333.333-33", "1985-03-03", NULL),
("JOAO CARLOS DE SOUZA", TRUE, "M", "444444444", "444.444.444-44", "1975-04-04", NULL),
("ANA PAULA OLIVEIRA", TRUE, "F", "555555555", "555.555.555-55", "1992-05-05", NULL),
("PEDRO HENRIQUE ALVES", TRUE, "M", "666666666", "666.666.666-66", "1988-06-06", NULL),
("MARCIA REGINA GOMES", TRUE, "F", "777777777", "777.777.777-77", "1970-07-07", NULL),
("ROBERTO SILVA SANTOS", TRUE, "M", "888888888", "888.888.888-88", "1995-08-08", NULL),
("CARLA CRISTINA DE SOUZA", TRUE, "F", "999999999", "999.999.999-99", "1982-09-09", NULL),
("FERNANDA COSTA LIMA", TRUE, "F", "101010101", "100.000.000-00", "1998-10-10", NULL);

-- 3. Faça um select que mostre as pessoas que tenha o código igual a 2;
SELECT * FROM Pessoa WHERE Codigo = 2;

-- 4. Faça um select que mostre as pessoas que tenha o nome igual a GUSTAVO;
SELECT * FROM Pessoa WHERE NOME LIKE '%GUSTAVO%';

-- 5. Faça um select que mostre as pessoas que o ÍNICIO do nome seja igual a MAR;
SELECT * FROM Pessoa WHERE NOME LIKE 'MAR%';

-- 6. Faça um select que mostre as pessoas que o FINAL do nome seja igual a OUZA;
SELECT * FROM Pessoa WHERE NOME LIKE '%OUZA';

-- 7. Faça um select que mostre as pessoas que tenha uma parte do nome que tenha a palavra SILVA;
SELECT * FROM Pessoa WHERE NOME LIKE '%SILVA%';

-- 8. Faça um select que mostre as pessoas que tenha uma parte do nome a palavra SILVA e a palavra OUZA;
SELECT * FROM Pessoa WHERE NOME LIKE '%SILVA%' AND NOME LIKE '%OUZA%';

-- 9. Faça um select que mostre as pessoas que tenha uma parte do nome COST ou AVO;
SELECT * FROM Pessoa WHERE NOME LIKE '%COST%' OR NOME LIKE '%AVO%';

-- 10. Altere sua tabela PESSOA e adicione o campo SEXO que será varchar de 1;
-- Já adicionado na Atividade 1.

-- 11. Faça um update para cada pessoa adicionando seus respectivos sexos.
-- Já atualizado na Atividade 1 e nas inserções acima.

-- 12. Faça um select que mostre as pessoas que sejam do sexo Feminino e tenha uma parte do nome MARIA
SELECT * FROM Pessoa WHERE Sexo = 'F' AND NOME LIKE '%MARIA%';

-- 13. Faça um select que mostre as pessoas que sejam do Sexo Masculino ou tenha o primeiro nome AGUINALDO.
SELECT * FROM Pessoa WHERE Sexo = 'M' OR NOME LIKE 'AGUINALDO%';

-- 14. Faça um select que mostre as pessoas que tenha os respectivos códigos: 3, 4, 7, 9, 1
SELECT * FROM Pessoa WHERE Codigo IN (3, 4, 7, 9, 1);

-- 15. Faça um select que mostre as pessoas que tenha o código MAIOR que 4;
SELECT * FROM Pessoa WHERE Codigo > 4;

-- 16. Faça um select que mostre as pessoas que tenha o código maior que 2 e menor que 6;
SELECT * FROM Pessoa WHERE Codigo > 2 AND Codigo < 6;

-- 17. Faça um select que mostre as pessoas que tenha somente o sexo Masculino.
SELECT * FROM Pessoa WHERE Sexo = 'M';

-- 18. Faça um select que mostre a quantidade de pessoas do sexo feminino.
SELECT COUNT(*) FROM Pessoa WHERE Sexo = 'F';

-- 19. Faça um select que mostre a quantidade de pessoas do Sexo Masculino.
SELECT COUNT(*) FROM Pessoa WHERE Sexo = 'M';

-- 20. Faça um select que mostre a quantidade de pessoas que tenha uma parte do nome MAR.
SELECT COUNT(*) FROM Pessoa WHERE NOME LIKE '%MAR%';
