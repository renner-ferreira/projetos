program ProjEstagiario;

uses
  Forms,
  MenuPrincipal in 'MenuPrincipal.pas' {TMenuPrincipal},
  DMPrincipal in 'DMPrincipal.pas' {TDMPrincipal: TDataModule},
  CLIENTE in 'CLIENTE.pas' {TCliente},
  CLIENTEC in 'CLIENTEC.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TTDMPrincipal, TDMPrincipal);
  Application.CreateForm(TTMenuPrincipal, TMenuPrincipal);
  Application.Run;
end.
