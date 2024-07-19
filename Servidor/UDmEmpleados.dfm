object DmEmpleados: TDmEmpleados
  Height = 242
  Width = 304
  object connDB: TFDConnection
    Params.Strings = (
      'Database=recursoshumanos'
      'User_Name=root'
      'Password=prueba'
      'DriverID=mySQL')
    Connected = True
    Left = 16
    Top = 8
  end
  object FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink
    VendorHome = 'C:\Users\juanc\Downloads\libmysql'
    VendorLib = 'LIBMYSQL.DLL'
    Left = 120
    Top = 168
  end
  object qInsertarEmpleados: TFDQuery
    Connection = connDB
    SQL.Strings = (
      'INSERT INTO recursoshumanos.funcionarios'
      
        '(fun_cidentificacion, fun_cnombres, fun_capellidos, fun_cargo, f' +
        'un_dep_nid, fun_fecha_ingreso)'
      
        'VALUES(:fun_cidentificacion, :fun_cnombres, :fun_capellidos, :fu' +
        'n_cargo, :fun_dep_nid, :fun_fecha_ingreso);')
    Left = 16
    Top = 72
    ParamData = <
      item
        Name = 'FUN_CIDENTIFICACION'
        ParamType = ptInput
      end
      item
        Name = 'FUN_CNOMBRES'
        ParamType = ptInput
      end
      item
        Name = 'FUN_CAPELLIDOS'
        ParamType = ptInput
      end
      item
        Name = 'FUN_CARGO'
        ParamType = ptInput
      end
      item
        Name = 'FUN_DEP_NID'
        ParamType = ptInput
      end
      item
        Name = 'FUN_FECHA_INGRESO'
        ParamType = ptInput
      end>
  end
  object qConsultarDependencias: TFDQuery
    Connection = connDB
    SQL.Strings = (
      'select * from dependencias')
    Left = 16
    Top = 128
  end
  object FDStanStorageJSONLink1: TFDStanStorageJSONLink
    Left = 24
    Top = 192
  end
end
