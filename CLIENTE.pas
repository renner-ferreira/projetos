unit CLIENTE;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, DBGrids, ExtCtrls, DBCtrls,
  CLIENTEC, DB, ADODB;

type
  TTCliente = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    dbGridCliente: TDBGrid;
    edPesquisa: TEdit;
    btnLimpar: TBitBtn;
    btnFechar: TBitBtn;
    BtnExcluir: TBitBtn;
    BtnEditar: TBitBtn;
    BtnInserir: TBitBtn;
    DBNavigator1: TDBNavigator;
    RadioGroup: TRadioGroup;
    Lab1: TLabel;
    LabNumeroRegistro: TLabel;
    Btnconsultar: TBitBtn;
    QCliente: TADOQuery;
    dsCliente: TDataSource;
    lbPesquisa: TLabel;

    procedure BTNINSERIRClick(Sender: TObject);
    procedure BtnEditarClick(Sender: TObject);
    procedure BtnExcluirClick(Sender: TObject);
    procedure btnConsultarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure edPesquisaKeyPress(Sender: TObject; var Key: Char);
    procedure RadioGroupClick(Sender: TObject);
    procedure AtualizarContador;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnLimparKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure BtnconsultarKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbGridClienteTitleClick(Column: TColumn);


  private
    ColunaPesquisa: string;

  public
    procedure ChamaTela;
  end;

var
  TCliente: TTCliente;

implementation

uses MenuPrincipal, DMPrincipal;

{$R *.dfm}


procedure TTCliente.BTNINSERIRClick(Sender: TObject);
begin
  TClienteC.ChamaTela('I', '');
end;


procedure TTCliente.BtnconsultarKeyDown(Sender: TObject; var Key: Word;
Shift: TShiftState);
begin
  if Key = VK_F3 then
  begin
    BtnconsultarClick(Self);
  end;
end;

procedure TTCliente.BtnEditarClick(Sender: TObject);
var
//  FrmEditar: TTClienteC;
  CodCliente: string;
begin
  if QCliente.IsEmpty then
  begin
    ShowMessage('Nenhum cliente selecionado.');
    Exit;
  end;

  CodCliente := QCliente.FieldByName('COD_CLIENT').AsString;
  TClientec.ChamaTela('E', QCliente.FieldByName('COD_CLIENT').AsString);

  with QCliente do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT COD_CLIENT, NOME, RG, CAST(ATIVO AS INTEGER) AS ATIVO');
    SQL.Add('FROM CLIENTE');
    SQL.Add('WHERE COD_CLIENT = ' + CodCliente);
    Open;
  end;

//  Nome := QCliente.FieldByName('Nome').AsString;
//  RG := QCliente.FieldByName('RG').AsString;
//  Ativo := QCliente.FieldByName('Ativo').AsInteger = 1;
//
//  FrmEditar := TTClienteC.Create(Self);
//  try
//    FrmEditar.CarregarCliente(Nome, RG, Ativo);
//    if FrmEditar.ShowModal = mrOk then
//    begin
//
//      QCliente.Edit;
//      QCliente.FieldByName('Nome').AsString := FrmEditar.edNome.Text;
//      QCliente.FieldByName('RG').AsString := FrmEditar.edRg.Text;
//      if FrmEditar.ativo.Checked then
//        QCliente.FieldByName('ATIVO').AsInteger := 1
//      else
//        QCliente.FieldByName('ATIVO').AsInteger := 0;
//      QCliente.Post;
//    end;
//  finally
//    FrmEditar.Free;
//  end;
end;

procedure TTCliente.BtnExcluirClick(Sender: TObject);
begin
  if not QCliente.IsEmpty then
  begin
    if MessageDlg('Deseja realmente excluir o cliente selecionado?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      with TDMPrincipal.QAux do
      begin
        Close;
        SQL.Clear;
        SQL.Add('DELETE FROM CLIENTE');
        SQL.Add('WHERE COD_CLIENT = '+
        QCliente.FieldByName('COD_CLIENT').AsString);
        ExecSQL;
      end;
     QCliente.Close;
      QCliente.Open;
      AtualizarContador;
    end;
  end;
end;

procedure TTCliente.btnConsultarClick(Sender: TObject);
begin
//  if not Assigned(dsCliente.DataSet) or dsCliente.DataSet.IsEmpty then
//    Exit;
  if QCliente.IsEmpty then
    Exit;

//  Nome := dsCliente.DataSet.FieldByName('NOME').AsString;
//  RG := dsCliente.DataSet.FieldByName('RG').AsString;
  TClienteC.ChamaTela('C', QCliente.FieldByName('COD_CLIENT').AsString);
end;

procedure TTCliente.btnFecharClick(Sender: TObject);
begin
  Close;
end;


procedure TTCliente.btnLimparClick(Sender: TObject);

begin
  edPesquisa.Clear;
end;


procedure TTCliente.btnLimparKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);

begin
  begin
    if Key = VK_F6 then
    begin
      edPesquisa.Clear;
      RadioGroup.ItemIndex := 0;

    end;
  end;
end;


procedure TTCliente.edPesquisaKeyPress(Sender: TObject; var Key: Char);
var
  vCodigo: Integer;
begin
  if Key = #13 then
  begin
    with QCliente do
    begin
      Close;
      SQL.Clear;

      SQL.Add('SELECT COD_CLIENT, NOME, RG, CAST(ATIVO AS INTEGER) AS ATIVO');
      SQL.Add('FROM CLIENTE');
      SQL.Add('WHERE ' + ColunaPesquisa + ' = ' + QuotedStr(edPesquisa.Text));
//
//      if Trim(edPesquisa.Text) = '*' then
//      begin
//        SQL.Add('ORDER BY NOME');
//      end
//      else if TryStrToInt(edPesquisa.Text, vCodigo) then
//      begin
//        SQL.Add('WHERE COD_CLIENT = ' + IntToStr(vCodigo));
//      end
//      else if Trim(edPesquisa.Text) <> '' then
//      begin
//        SQL.Add('WHERE NOME LIKE ''%' + edPesquisa.Text + '%'' ' +
//                'OR RG LIKE ''%' + edPesquisa.Text + '%''');
//      end;
//
//      Open;
    end;

    AtualizarContador;
  end;
end;



procedure TTCliente.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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


procedure TTCliente.FormShow(Sender: TObject);
begin
  RadioGroupClick(Self);
  edPesquisa.SetFocus;
  ColunaPesquisa := 'NOME';
end;


procedure TTCliente.RadioGroupClick(Sender: TObject);
var
  CodCliente: string;
begin
  with QCliente do
  begin
    Close;
    SQL.Clear;

    SQL.Add('SELECT COD_CLIENT, NOME, RG, CAST(ATIVO AS INTEGER) AS ATIVO');
    SQL.Add('FROM CLIENTE');
    SQL.Add('WHERE 1=1');

    if Trim(edPesquisa.Text) <> '' then
    begin
      SQL.Add('AND (NOME LIKE ' + QuotedStr('%' + edPesquisa.Text + '%') +
       ' OR RG LIKE ' + QuotedStr('%' + edPesquisa.Text + '%') + ')');
    end;

    case RadioGroup.ItemIndex of
      0:
        SQL.Add('AND ATIVO = 1');
      1:
        SQL.Add('AND ATIVO = 0');
    end;
    Open;
  end;

  AtualizarContador;
end;

procedure TTCliente.AtualizarContador;
begin
  LabNumeroRegistro.Caption := IntToStr(QCliente.RecordCount);
end;

procedure TTCliente.ChamaTela;
begin
  TCliente := TTCliente.Create(Application);
  try
    TCliente.ShowModal;
  finally
    FreeAndNil(TCliente);
  end;
end;


procedure TTCliente.dbGridClienteTitleClick(Column: TColumn);
var
  I: Integer;
begin
  if Column.FieldName <> 'ATIVO' then
    ColunaPesquisa := Column.FieldName;

  begin
    ColunaPesquisa := Column.FieldName;

    for I := 0 to dbGridCliente.Columns.Count - 1 do
      if dbGridCliente.Columns[I].FieldName = 'ATIVO' then
      begin
        dbGridCliente.Columns[I].Title.Font.Color := clBlack;
      end
      else
      begin
        if dbGridCliente.Columns[I].FieldName <> Column.FieldName then
          dbGridCliente.Columns[I].Title.Font.Color := clBlack
        else
          dbGridCliente.Columns[I].Title.Font.Color := clRed;
      end;
  end;
end;
end.
