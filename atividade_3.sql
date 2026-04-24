PRAGMA foreign_keys = ON;

-- 1. Crie uma tabela para armazenar tipos de logradouros.
CREATE TABLE Tipo_Logradouro (
    Codigo INTEGER PRIMARY KEY AUTOINCREMENT,
    Descricao VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO Tipo_Logradouro (Descricao) VALUES
("Rua"),
("Avenida"),
("Rodovia"),
("Praça"),
("Alameda");

-- 2. Crie uma tabela para armazenar logradouros.
CREATE TABLE Logradouro (
    Codigo INTEGER PRIMARY KEY AUTOINCREMENT,
    Codigo_Tipo_Logradouro INTEGER NOT NULL,
    Nome VARCHAR(255) NOT NULL,
    FOREIGN KEY (Codigo_Tipo_Logradouro) REFERENCES Tipo_Logradouro(Codigo)
);

INSERT INTO Logradouro (Codigo_Tipo_Logradouro, Nome) VALUES
(1, "Das Flores"),
(2, "Brasil"),
(1, "XV de Novembro"),
(3, "Anhanguera");

-- 3. Crie uma tabela para armazenar bairros.
CREATE TABLE Bairro (
    Codigo INTEGER PRIMARY KEY AUTOINCREMENT,
    Nome VARCHAR(255) NOT NULL UNIQUE
);

INSERT INTO Bairro (Nome) VALUES
("Centro"),
("Jardim América"),
("Vila Nova");

-- 5. Crie uma tabela para armazenar todos os estados. Não se esqueça da sigla.
CREATE TABLE Estado (
    Codigo INTEGER PRIMARY KEY AUTOINCREMENT,
    Nome VARCHAR(255) NOT NULL UNIQUE,
    Sigla CHAR(2) NOT NULL UNIQUE
);

INSERT INTO Estado (Nome, Sigla) VALUES
("São Paulo", "SP"),
("Rio de Janeiro", "RJ"),
("Minas Gerais", "MG");

-- 4. Crie uma tabela para armazenar municípios (agora depois de Estado).
CREATE TABLE Municipio (
    Codigo INTEGER PRIMARY KEY AUTOINCREMENT,
    Nome VARCHAR(255) NOT NULL,
    Codigo_Estado INTEGER NOT NULL,
    FOREIGN KEY (Codigo_Estado) REFERENCES Estado(Codigo)
);

INSERT INTO Municipio (Nome, Codigo_Estado) VALUES
("São Paulo", 1),
("Campinas", 1),
("Rio de Janeiro", 2),
("Belo Horizonte", 3);

-- 6. Crie uma tabela para armazenar os domicílios (os endereços). Não se esqueça do número.
CREATE TABLE Domicilio (
    Codigo INTEGER PRIMARY KEY AUTOINCREMENT,
    Numero VARCHAR(10) NOT NULL,
    Complemento VARCHAR(100),
    Codigo_Logradouro INTEGER NOT NULL,
    Codigo_Bairro INTEGER NOT NULL,
    Codigo_Municipio INTEGER NOT NULL,
    FOREIGN KEY (Codigo_Logradouro) REFERENCES Logradouro(Codigo),
    FOREIGN KEY (Codigo_Bairro) REFERENCES Bairro(Codigo),
    FOREIGN KEY (Codigo_Municipio) REFERENCES Municipio(Codigo)
);

INSERT INTO Domicilio (Numero, Complemento, Codigo_Logradouro, Codigo_Bairro, Codigo_Municipio) VALUES
("100", "Apto 10", 1, 1, 1),
("250", NULL, 2, 2, 2),
("30", "Casa", 3, 1, 3);

-- 7. Altere a tabela pessoa e adicione o domicilio em que ela mora.
-- Primeiro, adicionamos a coluna sem a FK, pois a tabela Pessoa já existe e pode ter dados.
ALTER TABLE Pessoa ADD COLUMN Codigo_Domicilio INTEGER;

-- Em SQLite, adicionar uma FK a uma coluna existente é mais complexo e geralmente envolve recriar a tabela.
-- Para este exercício, vamos assumir que a FK será aplicada na criação da tabela ou que a integridade será mantida por aplicação.
-- Se fosse um banco de dados como PostgreSQL ou MySQL, poderíamos fazer:
-- ALTER TABLE Pessoa ADD CONSTRAINT fk_domicilio FOREIGN KEY (Codigo_Domicilio) REFERENCES Domicilio(Codigo);
-- Para SQLite, vamos apenas adicionar a coluna e confiar na integridade dos dados inseridos.

UPDATE Pessoa SET Codigo_Domicilio = 1 WHERE Codigo = 1;
UPDATE Pessoa SET Codigo_Domicilio = 2 WHERE Codigo = 2;
UPDATE Pessoa SET Codigo_Domicilio = 3 WHERE Codigo = 3;

-- 8. Faça um select para mostrar a pessoa e seu respectivo endereço.
SELECT
    P.Nome AS Nome_Pessoa,
    TL.Descricao AS Tipo_Logradouro,
    L.Nome AS Logradouro,
    D.Numero,
    D.Complemento,
    B.Nome AS Bairro,
    M.Nome AS Municipio,
    E.Sigla AS Estado
FROM
    Pessoa AS P
JOIN
    Domicilio AS D ON P.Codigo_Domicilio = D.Codigo
JOIN
    Logradouro AS L ON D.Codigo_Logradouro = L.Codigo
JOIN
    Tipo_Logradouro AS TL ON L.Codigo_Tipo_Logradouro = TL.Codigo
JOIN
    Bairro AS B ON D.Codigo_Bairro = B.Codigo
JOIN
    Municipio AS M ON D.Codigo_Municipio = M.Codigo
JOIN
    Estado AS E ON M.Codigo_Estado = E.Codigo;
