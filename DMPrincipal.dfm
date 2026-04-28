object TDMPrincipal: TTDMPrincipal
  OldCreateOrder = False
  Height = 183
  Width = 260
  object QAux: TADOQuery
    Connection = ADOConexao
    Parameters = <>
    Left = 144
    Top = 72
  end
  object ADOConexao: TADOConnection
    ConnectionString = 
      'Provider=SQLOLEDB.1;Persist Security Info=False;User ID=SA;Initi' +
      'al Catalog=ESTAGIARIO_RENNER;Data Source=LOCALHOST'
    Provider = 'SQLOLEDB.1'
    Left = 48
    Top = 72
  end
end
