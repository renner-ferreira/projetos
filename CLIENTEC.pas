unit CLIENTEC;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, DB, ADODB, Mask, DBCtrls;

type
  TTClientec = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    ATIVO: TCheckBox;
    Btnsalvar: TBitBtn;
    btncancelar: TBitBtn;
    lbNome: TLabel;
    lbRg: TLabel;
    edNome: TEdit;
    EdRg: TEdit;
    QCliente: TADOQuery;
    dsCliente: TDataSource;

    procedure BtnsalvarClick(Sender: TObject);
    procedure ATIVOClick(Sender: TObject);
    procedure btncancelarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  
  private
    xTipoAcao, xCodCliente: string;
    procedure CarregarCliente(pCodCliente: string);    
  public
     Function ChamaTela(pTipoAcao, pCodCliente: string): string;
//  class procedure ChamaTelaConsulta(Nome, RG : string);


  end;

 var
  TClientec: TTClientec;
implementation

uses DMPrincipal, Cliente;

{$R *.dfm}

procedure TTClienteC.CarregarCliente(pCodCliente: string);
begin
  with TDMPrincipal.QAux do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT *');
    SQL.Add('FROM CLIENTE');
    SQL.Add('WHERE COD_CLIENT = ' + pCodCliente);
    Open;
    if not IsEmpty then
    begin
      edNome.Text := FieldByName('NOME').AsString;
      edRG.Text := FieldByName('RG').AsString;

      if xTipoAcao = 'C' then
      begin
        edNome.Enabled := False;
        edRG.Enabled := False;
        BtnSalvar.Visible := False;
        ATIVO.Visible := False;
      end;
    end;
  end;
end;

procedure TTClientec.ATIVOClick(Sender: TObject);
begin
  if ativo.Checked then
  begin
    if ativo.CanFocus then
      ativo.SetFocus;
    exit;
  end;
end;

procedure TTClientec.btncancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TTClientec.BtnsalvarClick(Sender: TObject);
begin
  if edNome.Text = '' then
  begin
    // showMessage('informe seu nome !');
    if edNome.CanFocus then
      edNome.SetFocus;
    exit;
  end;

  if edRg.Text = '' then
  begin
    showMessAge('inform um RG!');
    if edRg.CanFocus then
      edRg.SetFocus;
    Exit;
  end;
  
  with TDMPrincipal.qAux do
  begin
    Close;
    SQL.Clear;

    if xTipoAcao = 'I' then
    begin
      SQL.Add('INSERT INTO CLIENTE (NOME, RG, ATIVO)');
      SQL.Add('VALUES (');
      SQL.Add(QuotedStr(edNome.Text));
      SQL.Add(',' + QuotedStr(edRg.Text) + ',');
      if ativo.Checked then
        SQL.Add('1')
      else
        SQL.Add('0');
      SQL.Add(')');
    end
    else
    begin
      SQL.Add('UPDATE CLIENTE SET');
      SQL.Add('NOME = ' + QuotedStr(edNome.Text));
      SQL.Add(', RG = ' + QuotedStr(edRg.Text) + ',');
      if ativo.Checked then
        SQL.Add('ATIVO = 1')
      else
        SQL.Add('ATIVO = 0');
      SQL.Add('WHERE COD_CLIENT = ' + xCodCliente);
    end;
    ExecSQL;
  end;
  Close;
end;

function TTClientec.ChamaTela(pTipoAcao, pCodCliente: string): string;
begin
  TClientec := TTClientec.Create(Application);
  with TClientec do
  begin
    xCodCliente := pCodCliente;
    xTipoAcao := pTipoAcao;
    if pTipoAcao <> 'I'  then
      CarregarCliente(pCodCliente);

    ShowModal;
    FreeAndNil(TClientec);
  end;
end;

procedure TTClientec.FormKeyDown(Sender: TObject; var Key: Word;
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
// class procedure TTClienteC.ChamaTelaConsulta(Nome, RG: string);
//begin
//  with TTClienteC.Create(nil) do
//  begin
//    try
//
//
//
//      ShowModal;
//    finally
//      Free;
//    end;
//  end;
//end;

end.
