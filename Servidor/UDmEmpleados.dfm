object DmEmpleados: TDmEmpleados
  Height = 372
  Width = 379
  object connDB: TFDConnection
    Params.Strings = (
      'Database=recursoshumanos'
      'User_Name=root'
      'Password=prueba'
      'DriverID=mySQL')
    Left = 32
    Top = 8
  end
  object FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink
    VendorHome = 'C:\Users\juanc\Downloads\libmysql'
    VendorLib = 'LIBMYSQL.DLL'
    Left = 136
    Top = 8
  end
  object qInsertarEmpleados: TFDQuery
    Connection = connDB
    SQL.Strings = (
      'INSERT INTO recursoshumanos.funcionarios'
      
        '(fun_cidentificacion, fun_cnombres, fun_capellidos, fun_cargo, f' +
        'un_dep_nid, fun_fecha_ingreso)'
      
        'VALUES(:fun_cidentificacion, :fun_cnombres, :fun_capellidos, :fu' +
        'n_cargo, :fun_dep_nid, :fun_fecha_ingreso);')
    Left = 32
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
    Left = 32
    Top = 128
  end
  object qListaEmpleados: TFDQuery
    Connection = connDB
    SQL.Strings = (
      
        'select f.*, d.dep_nombredependencia from dependencias d inner jo' +
        'in funcionarios f on D.dep_nid = f.fun_dep_nid ')
    Left = 32
    Top = 184
  end
  object qActualizarEmpleado: TFDQuery
    Connection = connDB
    SQL.Strings = (
      'UPDATE recursoshumanos.funcionarios'
      
        'SET  fun_cnombres=:fun_cnombres, fun_capellidos=:fun_capellidos,' +
        ' fun_cargo=:fun_cargo, fun_dep_nid=:fun_dep_nid WHERE fun_nid=:f' +
        'un_nid;')
    Left = 136
    Top = 72
    ParamData = <
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
        Name = 'FUN_NID'
        ParamType = ptInput
      end>
  end
  object qEliminarEmpleado: TFDQuery
    Connection = connDB
    SQL.Strings = (
      'delete from funcionarios where fun_nid = :fun_nid')
    Left = 144
    Top = 136
    ParamData = <
      item
        Name = 'FUN_NID'
        ParamType = ptInput
      end>
  end
  object qInsertarDependencia: TFDQuery
    Connection = connDB
    SQL.Strings = (
      'INSERT INTO recursoshumanos.dependencias'
      '(dep_nombredependencia)'
      'VALUES(:dep_nombredependencia);')
    Left = 144
    Top = 184
    ParamData = <
      item
        Name = 'DEP_NOMBREDEPENDENCIA'
        ParamType = ptInput
      end>
  end
end
