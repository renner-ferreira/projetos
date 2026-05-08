unit FORNECEDOR;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, DBCtrls, Grids, DBGrids, DB, ADODB;

type
  TTFornecedores = class(TForm)
    Panel1: TPanel;
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    Lab1: TLabel;
    LaBNumeroRegistro: TLabel;
    RadioGroup1: TRadioGroup;
    Panel2: TPanel;
    painel3: TPanel;
    lbPesquisa: TLabel;
    edPesquisa: TEdit;
    btnTrasferir: TBitBtn;
    btnInserir: TBitBtn;
    btnConsultar: TBitBtn;
    btnEditar: TBitBtn;
    BtnExcluir: TBitBtn;
    BtnFechar: TBitBtn;
    BtnLimpar: TBitBtn;
    QFornecedor: TADOQuery;
    dsFornecedor: TDataSource;
    procedure btnInserirClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnConsultarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure AtualizarContador;
    procedure FormShow(Sender: TObject);
    procedure BtnExcluirClick(Sender: TObject);
    procedure edPesquisaKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtnLimparKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
  public
    procedure FiltrarDados;
  end;

var
  TFornecedores: TTFornecedores;

implementation

uses FornecedorC, DMPrincipal;

{$R *.dfm}

procedure TTFornecedores.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
      begin
        Close;
      end;

    VK_F6:
      begin
        btnLimparClick(Self);
      end;

    VK_F3:
      begin
        BtnconsultarClick(Self);
      end;

    VK_F4:
      begin
        BtnEditarClick(Self);
      end;

    VK_F8:
      begin
        BtnExcluirClick(Self);
      end;

    Vk_F2:
      begin
        BTNINSERIRClick(Self);
      end;

//    VK_F12:
//      begin
//        BtnTransferirClick(Self);
//      end;

  end;
end;

procedure TTFornecedores.FormShow(Sender: TObject);
begin
dsFornecedor.DataSet := QFornecedor;
  DBGrid1.DataSource   := dsFornecedor;
  FiltrarDados;
  edPesquisa.SetFocus;
  RadioGroup1Click(Self);
end;

procedure TTFornecedores.FiltrarDados;
begin
  with QFornecedor do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT COD_FORNECEDOR, NOME_FANTASIA, CNPJ, CAST(ATIVO AS INTEGER) AS ATIVO');
    SQL.Add('FROM FORNECEDOR');
    SQL.Add('WHERE 1=1');

    if Trim(edPesquisa.Text) <> '' then
      SQL.Add('AND (NOME_FANTASIA LIKE ' + QuotedStr('%' + edPesquisa.Text + '%') + ' OR CNPJ LIKE ' + QuotedStr('%' + edPesquisa.Text + '%') + ')');

    case RadioGroup1.ItemIndex of
      0:
        SQL.Add('AND ATIVO = 1');
      1:
        SQL.Add('AND ATIVO = 0');
    end;
    Open;
  end;
end;

procedure TTFornecedores.btnInserirClick(Sender: TObject);
begin
  TFornecedorC.ChamaTelaFornecedor('I', '');
  FiltrarDados;
end;

procedure TTFornecedores.btnEditarClick(Sender: TObject);
var
Codfornecedor: string;
begin
  if QFornecedor.IsEmpty then
  begin
    ShowMessage('Nenhum cliente selecionado.');
    Exit;
  end;

  Codfornecedor := QFornecedor.FieldByName('COD_FORNECEDOR').AsString;
  TFornecedorC.ChamaTelaFornecedor('E', QFornecedor.FieldByName('COD_FORNECEDOR').AsString);

 with QFornecedor do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT COD_FORNECEDOR, NOME_FANTASIA, CNPJ, ATIVO');
    SQL.Add('FROM FORNECEDOR');
    SQL.Add('WHERE COD_FORNECEDOR = ' + Codfornecedor);
    Open;
  end;
end;

procedure TTFornecedores.btnConsultarClick(Sender: TObject);
begin

  if QFornecedor.IsEmpty then
    Exit;
  TFornecedorC.ChamaTelaFornecedor('C', QFornecedor.FieldByName
  ('COD_FORNECEDOR').AsString);
end;

procedure TTFornecedores.BtnExcluirClick(Sender: TObject);
begin
  if not QFornecedor.IsEmpty then
  begin
    if MessageDlg('Deseja realmente excluir o cliente selecionado?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      with TDMPrincipal.QAux do
      begin
        Close;
        SQL.Clear;
        SQL.Add('DELETE FROM FORNECEDOR');
        SQL.Add('WHERE COD_FORNECEDOR = '+
        QFornecedor.FieldByName('COD_FORNECEDOR').AsString);
        ExecSQL;
      end;
      QFornecedor.Close;
      QFornecedor.Open;
      AtualizarContador;
    end;
  end;
end;

procedure TTFornecedores.btnLimparClick(Sender: TObject);
begin
   edPesquisa.Clear;
end;

procedure TTFornecedores.BtnLimparKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
begin
  begin
    if Key = VK_F6 then
    begin
      edPesquisa.Clear;
      RadioGroup1.ItemIndex := 0;

    end;
  end;
end;
end;

procedure TTFornecedores.edPesquisaKeyPress(Sender: TObject; var Key: Char);
var
  vCodigo: Integer;
begin
  if Key = #13 then
  begin
    with QFornecedor do
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT COD_FORNECEDOR, NOME_FANTASIA AS NOME, CNPJ, CAST(ATIVO AS INTEGER) AS ATIVO');
      SQL.Add('FROM FORNECEDOR');

      if Trim(edPesquisa.Text) = '*' then
      begin

        SQL.Add('ORDER BY NOME_FANTASIA');
      end
      else if TryStrToInt(edPesquisa.Text, vCodigo) then
      begin

        SQL.Add('WHERE COD_FORNECEDOR = ' + IntToStr(vCodigo));
      end
      else if Trim(edPesquisa.Text) <> '' then
      begin

        SQL.Add('WHERE NOME_FANTASIA LIKE ' + QuotedStr('%' + edPesquisa.Text
         + '%'));
        SQL.Add('OR CNPJ LIKE ' + QuotedStr('%' + edPesquisa.Text + '%'));
      end;

      Open;
    end;


  end;
end;
procedure TTFornecedores.RadioGroup1Click(Sender: TObject);
var
  CodFornecedor: string;
begin
  with QFornecedor do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT COD_FORNECEDOR, NOME_FANTASIA AS NOME, CNPJ, CAST(ATIVO AS INTEGER) AS ATIVO');
    SQL.Add('FROM FORNECEDOR');
    SQL.Add('WHERE 1=1');

    if Trim(edPesquisa.Text) <> '' then
    begin
      SQL.Add('AND (NOME_FANTASIA LIKE ' + QuotedStr('%' + edPesquisa.Text + '%') +
       ' OR CNPJ LIKE ' + QuotedStr('%' + edPesquisa.Text + '%') + ')');
    end;

    case RadioGroup1.ItemIndex of
      0:
        SQL.Add('AND ATIVO = 1');
      1:
        SQL.Add('AND ATIVO = 0');
    end;
    Open;
  end;

  AtualizarContador;
end;

procedure TTFornecedores.btnFecharClick(Sender: TObject);
begin
  Close;
end;

 procedure TTFornecedores.AtualizarContador;
begin
  LabNumeroRegistro.Caption := IntToStr(QFornecedor.RecordCount);
end;


end.
