unit DMPrincipal;

interface

uses
  SysUtils, Classes, DB, ADODB;

type
  TTDMPrincipal = class(TDataModule)
    QAux: TADOQuery;
    ADOConexao: TADOConnection;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TDMPrincipal: TTDMPrincipal;

implementation

{$R *.dfm}

end.
