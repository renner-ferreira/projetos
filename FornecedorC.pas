unit FornecedorC;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, DB, ADODB;

type
  TTFornecedorC = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    lbNome: TLabel;
    EdNome: TEdit;
    LbCnpj: TLabel;
    Edcnpj: TEdit;
    CheckBox1: TCheckBox;
    btnsalvar: TBitBtn;
    BtnCancelar: TBitBtn;
    ATIVO: TCheckBox;
    procedure BtnCancelarClick(Sender: TObject);
    procedure btnsalvarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ATIVOClick(Sender: TObject);
  private
    xTipoAcao, xCodFornecedor: string;
    procedure CarregarFornecedor(pCodFornecedor: string);
  public
    function ChamaTelaFornecedor(pTipoAcao, pCodFornecedor: string): string;
  end;

var
  TFornecedorC: TTFornecedorC;

implementation

uses DMPrincipal;

{$R *.dfm}

function TTFornecedorC.ChamaTelaFornecedor(pTipoAcao, pCodFornecedor: string): string;
begin
  TFornecedorC := TTFornecedorC.Create(Application); // ISSO É O QUE VOCÊ PROVAVELMENTE ESQUECEU
  try
    TFornecedorC.xTipoAcao := pTipoAcao;
    TFornecedorC.xCodFornecedor := pCodFornecedor;
    if pTipoAcao <> 'I' then
       TFornecedorC.CarregarFornecedor(pCodFornecedor);
    TFornecedorC.ShowModal;
  finally
    FreeAndNil(TFornecedorC);
  end;
end;

procedure TTFornecedorC.ATIVOClick(Sender: TObject);
begin
  if ativo.Checked then
  begin
    if ativo.CanFocus then
      ativo.SetFocus;
    exit;
  end;
end;


procedure TTFornecedorC.btnsalvarClick(Sender: TObject);
begin
  if Trim(EdNome.Text) = '' then
  begin
    ShowMessage('Informe o Nome!');
    EdNome.SetFocus;
    Exit;
  end;

  with TDMPrincipal.qAux do
  begin
    Close;
    SQL.Clear;
    if xTipoAcao = 'I' then
    begin
      SQL.Add('INSERT INTO FORNECEDOR (NOME_FANTASIA, CNPJ, ATIVO)');
      SQL.Add('VALUES (' + QuotedStr(EdNome.Text) + ',');
      SQL.Add(QuotedStr(Edcnpj.Text) + ',');
       if ativo.Checked then
        SQL.Add('1')
      else
        SQL.Add('0');
      SQL.Add(')');
    end
    else
    begin
      SQL.Add('UPDATE FORNECEDOR SET');
      SQL.Add('NOME_FANTASIA = ' + QuotedStr(EdNome.Text) + ',');
      SQL.Add('CNPJ = ' + QuotedStr(Edcnpj.Text) + ',');
     if ativo.Checked then
        SQL.Add('ATIVO = 1')
      else
        SQL.Add('ATIVO = 0');
      SQL.Add('WHERE COD_FORNECEDOR = ' + xCodFornecedor);
    end;
    ExecSQL;
  end;
  Close;
end;

procedure TTFornecedorC.BtnCancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TTFornecedorC.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
      begin
        btncancelarClick(Self);
      end;

    VK_F5:
      begin
        BtnsalvarClick(Self);
      end;
  end;
end;

  procedure TTFornecedorC.CarregarFornecedor(pCodFornecedor: string);
begin
  with TDMPrincipal.QAux do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT *');
    SQL.Add('FROM FORNECEDOR');
    SQL.Add('WHERE COD_FORNECEDOR = ' + pCodFornecedor);
    Open;
    if not IsEmpty then
    begin
      edNome.Text := FieldByName('NOME_FANTASIA').AsString;
      Edcnpj.Text := FieldByName('CNPJ').AsString;

      if xTipoAcao = 'C' then
      begin
        edNome.Enabled := False;
        Edcnpj.Enabled := False;
        BtnSalvar.Visible := False;
        ATIVO.Visible := False;
      end;
    end;
  end;
end;



end.
