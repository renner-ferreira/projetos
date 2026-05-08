object TDMPrincipal: TTDMPrincipal
  OldCreateOrder = False
  Height = 183
  Width = 260
  object QAux: TADOQuery
    Connection = ADOConexao
    Parameters = <>
    SQL.Strings = (
      '')
    Left = 144
    Top = 72
  end
  object ADOConexao: TADOConnection
    Connected = True
    ConnectionString = 
      'Provider=SQLOLEDB.1;Password=14;Persist Security Info=True;User ' +
      'ID=SA;Initial Catalog=ESTAGIARIO_RENNER;Data Source=LOCALHOST'
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 48
    Top = 72
  end
end
