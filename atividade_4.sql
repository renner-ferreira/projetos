PRAGMA foreign_keys = ON;

-- 1. Crie uma tabela CARRO que tenha uma chave primária, nome, ano, cor, e o código da pessoa (chave estrangeira).
CREATE TABLE Carro (
    Codigo INTEGER PRIMARY KEY AUTOINCREMENT,
    Nome VARCHAR(255) NOT NULL,
    Ano INTEGER,
    Cor VARCHAR(50),
    Codigo_Pessoa INTEGER NOT NULL,
    FOREIGN KEY (Codigo_Pessoa) REFERENCES Pessoa(Codigo)
);

-- 2. Insira registros nessa tabela, colocando os códigos das respectivas pessoas. (Toda pessoa deve ter um carro)
INSERT INTO Carro (Nome, Ano, Cor, Codigo_Pessoa) VALUES
("Fusca", 1970, "Azul", 1),
("Opala", 1975, "Preto", 2),
("Chevette", 1980, "Branco", 3),
("Gol", 2000, "Prata", 4),
("Palio", 2010, "Vermelho", 5),
("Civic", 2015, "Cinza", 7); -- Mariana Costa

-- 3. Tente excluir a pessoa de código 6.
-- A pessoa de código 6 não existe, então a exclusão não terá efeito.
-- Se existisse e tivesse um carro associado, a exclusão falharia devido à FK, a menos que a FK fosse ON DELETE CASCADE.
DELETE FROM Pessoa WHERE Codigo = 6;

-- 4. Faça um select que mostre todas as informações do carro, código e nome da pessoa a que ele pertence.
SELECT
    C.Codigo AS Codigo_Carro,
    C.Nome AS Nome_Carro,
    C.Ano,
    C.Cor,
    P.Codigo AS Codigo_Pessoa,
    P.Nome AS Nome_Pessoa
FROM
    Carro AS C
JOIN
    Pessoa AS P ON C.Codigo_Pessoa = P.Codigo;
