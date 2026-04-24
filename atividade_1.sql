PRAGMA foreign_keys = ON;

-- 1. Crie um banco chamado ESTAGIARIO_MANUS
-- Em SQLite, criar um banco é simplesmente criar um arquivo de banco de dados. Vamos usar 'estagiario_manus.db'.

-- 2. Crie uma tabela chamada Pessoa
CREATE TABLE Pessoa (
    Codigo INTEGER PRIMARY KEY AUTOINCREMENT,
    Nome VARCHAR(255) NOT NULL
);

-- 3. Insira registros na tabela Pessoa
INSERT INTO Pessoa (Nome) VALUES
('João Silva'),
('Maria Souza'),
('Pedro Santos'),
('Ana Oliveira'),
('Carlos Pereira');

-- 4. Crie uma tabela chamada Telefone_Pessoa
CREATE TABLE Telefone_Pessoa (
    Codigo INTEGER PRIMARY KEY AUTOINCREMENT,
    Codigo_Pessoa INTEGER NOT NULL,
    DDD VARCHAR(3),
    Numero VARCHAR(10),
    FOREIGN KEY (Codigo_Pessoa) REFERENCES Pessoa(Codigo)
);

-- 5. Insira registros na tabela Telefone_Pessoa
INSERT INTO Telefone_Pessoa (Codigo_Pessoa, DDD, Numero) VALUES
(1, '11', '987654321'),
(1, '21', '912345678'),
(2, '31', '998765432'),
(3, '41', '987612345'),
(5, '51', '991234567');

-- 6. Adicione um campo 'ativo' do tipo Booleano na tabela Pessoa
ALTER TABLE Pessoa ADD COLUMN Ativo BOOLEAN DEFAULT TRUE;

-- 7. Altere as pessoas inseridas na tabela Pessoa, colocando se estão ativas ou inativas
UPDATE Pessoa SET Ativo = FALSE WHERE Codigo = 2;
UPDATE Pessoa SET Ativo = TRUE WHERE Codigo = 1;
UPDATE Pessoa SET Ativo = FALSE WHERE Codigo = 4;

-- 8. Adiciona um campo 'sexo' onde será inserido apenas F ou M
ALTER TABLE Pessoa ADD COLUMN Sexo CHAR(1);

-- 9. Altere as pessoas inseridas na tabela Pessoa, colocando os respectivos sexos
UPDATE Pessoa SET Sexo = 'M' WHERE Codigo = 1;
UPDATE Pessoa SET Sexo = 'F' WHERE Codigo = 2;
UPDATE Pessoa SET Sexo = 'M' WHERE Codigo = 3;
UPDATE Pessoa SET Sexo = 'F' WHERE Codigo = 4;
UPDATE Pessoa SET Sexo = 'M' WHERE Codigo = 5;

-- 10. Tente excluir uma Pessoa (com chave estrangeira)
-- Esta operação deve falhar devido à restrição de chave estrangeira, a menos que a pessoa não tenha telefones associados ou a FK seja ON DELETE CASCADE.
-- Vamos tentar excluir uma pessoa que tem telefones associados (João Silva - Codigo 1)
DELETE FROM Pessoa WHERE Codigo = 1;

-- Para demonstrar a exclusão bem-sucedida de uma pessoa sem telefones, vamos inserir uma nova pessoa e tentar excluí-la.
INSERT INTO Pessoa (Nome, Ativo, Sexo) VALUES ('Nova Pessoa', TRUE, 'F');
DELETE FROM Pessoa WHERE Nome = 'Nova Pessoa';

-- Selecionar todos os dados para verificar as alterações
SELECT * FROM Pessoa;
SELECT * FROM Telefone_Pessoa;
