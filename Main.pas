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
    QconsultaITEM: TStringField;
    QconsultaID_N: TStringField;
    QconsultaCOMPANY: TStringField;
    QconsultaPERIODO: TStringField;
    QconsultaFECHA: TSQLTimeStampField;
    QconsultaTIPO: TStringField;
    QconsultaBATCH: TIntegerField;
    QconsultaQTY: TFloatField;
    QconsultaVALUNIT: TFloatField;
    QconsultaTOTPARCIAL: TFloatField;
    Button1: TButton;
    QconsultaLOCATION: TStringField;
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
  if ListBox1.Items.Count = 0 then
  begin
    ShowMessage('Debe Agragar Al Menos un item');
    exit;
  end;

  Qconsulta.Close;
  Qconsulta.SQL.Clear;
  Qconsulta.SQL.Add
    (' SELECT  I.ITEM,I.ID_N,C.COMPANY,I.FECHA,I.TIPO,I.BATCH,I.QTY,I.VALUNIT,I.TOTPARCIAL,'
    + ' (extract(year from I.FECHA) || substring((extract(month from I.FECHA) + 100) from 2 for 2)) as PERIODO,I.LOCATION'
    + ' FROM ITEMACT I INNER JOIN CUST C ON I.ID_N= C.ID_N WHERE FECHA between :FI AND :FF AND( ');
  H := 0;
  for I := 0 to ListBox1.Items.Count - 1 do
  begin
    if H = 0 then
      Qconsulta.SQL.Add('I.ITEM = ' + QuotedStr(ListBox1.Items[I]) + ' ')
    ELSE
      Qconsulta.SQL.Add(' OR I.ITEM = ' + QuotedStr(ListBox1.Items[I]) + ' ');

    H := H + 1;
  end;
  Qconsulta.SQL.Add(' ) ORDER by I.ITEM, PERIODO ');
  Qconsulta.ParamByName('FI').AsDate := DateEdit1.Date;
  Qconsulta.ParamByName('FF').AsDate := DateEdit2.Date;
  Qconsulta.Open;
  // uses ComObj;
  // Crea una aplicacion Excel.
  Excel := CreateOleObject('Excel.Application');
  // La muestra (vas a ver un Excel como si lu ubieras ejecutado)
  Excel.Visible := True;
  // Agrega un libro.
  Excel.WorkBooks.Add(-4167);
  // Le asigna un nombre al libro
  Excel.WorkBooks[1].WorkSheets[1].Name := 'Reporte';
  // Hace un puntero al libro del Excel.
  Libro := Excel.WorkBooks[1].WorkSheets['Reporte'];
  Qconsulta.First;
  I := 2;
  Libro.Cells[1, 1] := 'ITEM';
  Libro.Cells[1, 2] := 'NIT';
  Libro.Cells[1, 3] := 'CLIENTE';
  Libro.Cells[1, 4] := 'PERIODO';
  Libro.Cells[1, 5] := 'FECHA';
  Libro.Cells[1, 6] := 'TIPO';
  Libro.Cells[1, 7] := 'NUMERO';
  Libro.Cells[1, 8] := 'CANTIDAD';
  Libro.Cells[1, 9] := 'VALOR UNITARIO';
  Libro.Cells[1, 10] := 'TOTAL PARCIAL';
  Libro.Cells[1, 11] := 'BODEGA';
  while not Qconsulta.Eof do
  begin

    Libro.Cells[I, 1] := QconsultaITEM.AsString;
    Libro.Cells[I, 2] := QconsultaID_N.AsString;
    Libro.Cells[I, 3] := QconsultaCOMPANY.AsString;
    Libro.Cells[I, 4] := QconsultaPERIODO.AsString;
    Libro.Cells[I, 5] := FormatDateTime('yyyy/mm/dd',
      QconsultaFECHA.AsDateTime);
    Libro.Cells[I, 6] := QconsultaTIPO.AsString;
    Libro.Cells[I, 7] := QconsultaBATCH.AsInteger;
    Libro.Cells[I, 8] := QconsultaQTY.AsFloat;
    Libro.Cells[I, 9] := QconsultaVALUNIT.AsFloat;
    Libro.Cells[I, 10] := QconsultaTOTPARCIAL.AsFloat;
    Libro.Cells[I, 11] := QconsultaLOCATION.AsString;
    Qconsulta.Next;
    I := I + 1;
  END;
end;

end.
