unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.DateTimeCtrls, FMX.Layouts, FMX.ListBox, FMX.Edit,
  FMX.Controls.Presentation, FMX.SearchBox, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.FMXUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, ComObj;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Edit1: TEdit;
    AddItem: TButton;
    ListBox1: TListBox;
    DateEdit1: TDateEdit;
    DateEdit2: TDateEdit;
    Label1: TLabel;
    Label2: TLabel;
    Generar: TButton;
    Conexion: TFDConnection;
    Qconsulta: TFDQuery;
    Button1: TButton;
    Edit2: TEdit;
    Label3: TLabel;
    QconsultaITEM: TStringField;
    QconsultaID_N: TStringField;
    QconsultaCOMPANY: TStringField;
    QconsultaPERIODO: TStringField;
    QconsultaFECHA: TSQLTimeStampField;
    QconsultaTIPO: TStringField;
    QconsultaNUMBER: TIntegerField;
    QconsultaQTYSHIP: TFloatField;
    QconsultaPRICE: TFloatField;
    QconsultaEXTEND: TFloatField;
    QconsultaCOST: TFloatField;
    QconsultaCOSTO_TOTAL: TFloatField;
    QconsultaMARGEN: TFloatField;
    QconsultaLOCATION: TStringField;
    QEnsamble: TFDQuery;
    QEnsambleITEM: TStringField;
    QEnsambleID_N: TStringField;
    QEnsambleCOMPANY: TStringField;
    QEnsamblePERIODO: TStringField;
    QEnsambleFECHA: TSQLTimeStampField;
    QEnsambleTIPO: TStringField;
    QEnsambleBATCH: TIntegerField;
    QEnsambleQTY: TFloatField;
    QEnsambleVALUNIT: TFloatField;
    QEnsambleTOTPARCIAL: TFloatField;
    QEnsambleLOCATION: TStringField;
    procedure AddItemClick(Sender: TObject);
    procedure GenerarClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.AddItemClick(Sender: TObject);
begin
  if Edit1.Text <> '' then
  BEGIN
    ListBox1.Items.Add(Edit1.Text);
  END;
  Edit1.Text := '';

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  ListBox1.Items.Delete(ListBox1.Items.Count - 1);
end;

procedure TForm1.GenerarClick(Sender: TObject);
VAR
  I, H: Integer;
  Excel, Libro: Variant;
begin

  if Edit2.Text = '' then
  begin
    ShowMessage('Falta La Direccion de la base de datos!!');
    exit;
  end;

  if ListBox1.Items.Count = 0 then
  begin
    ShowMessage('Debe Agragar Al Menos un item');
    exit;
  end;
  Conexion.Connected := False;
  Conexion.Params.VALUES['driverid'] := 'FB';
  Conexion.Params.VALUES['DATABASE'] := Edit2.Text;
  Conexion.Params.VALUES['user_name'] := 'SYSDBA';
  Conexion.Params.VALUES['PASSWORD'] := 'masterkey';
  Conexion.Params.VALUES['Protocol'] := 'ipTCPIP';

  Qconsulta.Close;
  Qconsulta.SQL.Clear;
  Qconsulta.SQL.Add
    (' SELECT O1.ITEM,C.ID_N,C.COMPANY ,(extract(year from O.FECHA) || substring((extract(month from O.FECHA) + 100) from 2 for 2)) as PERIODO,'
    + ' O.FECHA,O.TIPO,O.NUMBER,ROUND(O1.QTYSHIP,2)QTYSHIP,ROUND(O1.PRICE,2)PRICE,ROUND(O1.EXTEND,2)EXTEND,O1.COST,ROUND((O1.COST*O1.QTYSHIP),2) COSTO_TOTAL,'
    + ' ROUND(((O1.EXTEND-(O1.COST*O1.QTYSHIP))/O1.EXTEND)*100,2) AS MARGEN,O1.LOCATION FROM OE O '
    + ' INNER JOIN OEDET O1 ON O.TIPO = O1.TIPO AND O.NUMBER =O1.NUMBER' +
    ' INNER JOIN CUST C ON O.ID_N= C.ID_N' +
    ' WHERE O.FECHA between :FI AND :FF AND O1.QTYSHIP <>0 AND ( ');
  H := 0;
  for I := 0 to ListBox1.Items.Count - 1 do
  begin
    if H = 0 then
      Qconsulta.SQL.Add('O1.ITEM = ' + QuotedStr(ListBox1.Items[I]) + ' ')
    ELSE
      Qconsulta.SQL.Add(' OR O1.ITEM = ' + QuotedStr(ListBox1.Items[I]) + ' ');

    H := H + 1;
  end;
  Qconsulta.SQL.Add(' )AND  O.TIPO in (select T.CLASE from TIPDOC T where T.TIPO = ''FA'')  ORDER by O1.ITEM, PERIODO,O.NUMBER ');
  Qconsulta.ParamByName('FI').AsDate := DateEdit1.Date;
  Qconsulta.ParamByName('FF').AsDate := DateEdit2.Date;
  Qconsulta.Open;
  Excel := CreateOleObject('Excel.Application');
  Excel.Visible := True;
  Excel.WorkBooks.Add(-4167);
  Excel.WorkBooks[1].WorkSheets.Add;
  Excel.WorkBooks[1].WorkSheets[1].Name := 'Facturas';

  Excel.WorkBooks[1].WorkSheets[2].Name := 'ensambles';
  Libro := Excel.WorkBooks[1].WorkSheets['Facturas'];
  Qconsulta.First;
  I := 2;

  Libro.Cells[1, 1] := 'NIT';
  Libro.Cells[1, 2] := 'CLIENTE';
  Libro.Cells[1, 3] := 'PERIODO';
  Libro.Cells[1, 4] := 'FECHA';
  Libro.Cells[1, 5] := 'TIPO';
  Libro.Cells[1, 6] := 'NUMERO';
  Libro.Cells[1, 7] := 'ITEM';
  Libro.Cells[1, 8] := 'BODEGA';
  Libro.Cells[1, 9] := 'CANTIDAD';
  Libro.Cells[1, 10] := 'COSTO UNITARIO';
  Libro.Cells[1, 11] := 'COSTO TOTAL';
  Libro.Cells[1, 12] := 'PRECIO UNITARIO';
  Libro.Cells[1, 13] := 'PRECIO DE VENTA';
  Libro.Cells[1, 14] := 'MARGEN';
  while not Qconsulta.Eof do
  begin
    Libro.Cells[I, 1] := QconsultaID_N.AsString;
    Libro.Cells[I, 2] := QconsultaCOMPANY.AsString;
    Libro.Cells[I, 3] := QconsultaPERIODO.AsString;
    Libro.Cells[I, 4] := FormatDateTime('yyyy/mm/dd',
      QconsultaFECHA.AsDateTime);
    Libro.Cells[I, 5] := QconsultaTIPO.AsString;
    Libro.Cells[I, 6] := QconsultaNUMBER.AsInteger;
    Libro.Cells[I, 7] := QconsultaITEM.AsString;
    Libro.Cells[I, 8] := QconsultaLOCATION.AsString;
    Libro.Cells[I, 9] := QconsultaQTYSHIP.AsFloat;
    Libro.Cells[I, 10] := QconsultaCOST.AsFloat;
    Libro.Cells[I, 11] := QconsultaCOSTO_TOTAL.AsFloat;
    Libro.Cells[I, 12] := QconsultaPRICE.AsFloat;
    Libro.Cells[I, 13] := QconsultaEXTEND.AsFloat;
    Libro.Cells[I, 14] := QconsultaMARGEN.AsFloat;
    Qconsulta.Next;
    I := I + 1;
  END;
  QEnsamble.Close;
  QEnsamble.SQL.Clear;
  QEnsamble.SQL.Add
    (' SELECT  I.ITEM,I.ID_N,C.COMPANY,(extract(year from I.FECHA) || substring((extract(month from I.FECHA) + 100) from 2 for 2)) as PERIODO,'
    + ' I.FECHA,I.TIPO,I.BATCH,IIF(I.QTY <0,I.QTY*(-1),I.QTY )QTY,ROUND(I.VALUNIT,2)VALUNIT,ROUND(I.VALUNIT*IIF(I.QTY <0,I.QTY*(-1),I.QTY ),2)TOTPARCIAL,I.LOCATION'
    + ' FROM ITEMACT I INNER JOIN CUST C ON I.ID_N= C.ID_N WHERE FECHA between :FI AND :FF AND QTY <>0 AND ( ');
  H := 0;
  for I := 0 to ListBox1.Items.Count - 1 do
  begin
    if H = 0 then
      QEnsamble.SQL.Add('I.ITEM = ' + QuotedStr(ListBox1.Items[I]) + ' ')
    ELSE
      QEnsamble.SQL.Add(' OR I.ITEM = ' + QuotedStr(ListBox1.Items[I]) + ' ');

    H := H + 1;
  end;
  QEnsamble.SQL.Add(' )AND I.TIPO in (select T.CLASE from TIPDOC T where T.TIPO = ''EN'')  ORDER by I.ITEM, PERIODO,I.BATCH ');
  QEnsamble.ParamByName('FI').AsDate := DateEdit1.Date;
  QEnsamble.ParamByName('FF').AsDate := DateEdit2.Date;
  QEnsamble.Open;

  Libro := Excel.WorkBooks[1].WorkSheets['ensambles'];
  Qconsulta.First;
  I := 2;

  Libro.Cells[1, 1] := 'NIT';
  Libro.Cells[1, 2] := 'CLIENTE';
  Libro.Cells[1, 3] := 'PERIODO';
  Libro.Cells[1, 4] := 'FECHA';
  Libro.Cells[1, 5] := 'TIPO';
  Libro.Cells[1, 6] := 'NUMERO';
  Libro.Cells[1, 7] := 'ITEM';
  Libro.Cells[1, 8] := 'BODEGA';
  Libro.Cells[1, 9] := 'CANTIDAD';
  Libro.Cells[1, 10] := 'COSTO UNITARIO';
  Libro.Cells[1, 11] := 'COSTO TOTAL';


   while not QEnsamble.Eof do
  begin
    Libro.Cells[I, 1] := QEnsambleID_N.AsString;
    Libro.Cells[I, 2] := QEnsambleCOMPANY.AsString;
    Libro.Cells[I, 3] := QEnsamblePERIODO.AsString;
    Libro.Cells[I, 4] := FormatDateTime('yyyy/mm/dd',
      QconsultaFECHA.AsDateTime);
    Libro.Cells[I, 5] := QEnsambleTIPO.AsString;
    Libro.Cells[I, 6] := QEnsambleBATCH.AsInteger;
    Libro.Cells[I, 7] := QEnsambleITEM.AsString;
    Libro.Cells[I, 8] := QEnsambleLOCATION.AsString;
    Libro.Cells[I, 9] := QEnsambleQTY.AsFloat;
    Libro.Cells[I, 10] := QEnsambleVALUNIT.AsFloat;
    Libro.Cells[I, 11] := QEnsambleTOTPARCIAL.AsFloat;
    QEnsamble.Next;
    I := I + 1;
  END;
end;

end.
