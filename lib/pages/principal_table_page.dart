import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:daily_sales/services/firestore_service.dart'; // Your FirestoreService
import 'package:daily_sales/models/principal_table_data.dart'; // Your PrincipalTableData model
import 'package:daily_sales/utils/utils.dart';

class PrincipalTablePage extends StatefulWidget {
  @override
  _PrincipalTablePageState createState() => _PrincipalTablePageState();
}

class _PrincipalTablePageState extends State<PrincipalTablePage> {
  late PrincipalTableDataSource principalDataSource;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PrincipalTableData>>(
      stream: FirestoreService().getPrincipalTableData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading data'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        // Assign data to the datasource
        principalDataSource = PrincipalTableDataSource(snapshot.data!);

        return SfDataGrid(
          headerRowHeight: 40, // Adjust this value to your desired height
          rowHeight: 40, // Adjust this value to your desired height
          source: principalDataSource,
          gridLinesVisibility: GridLinesVisibility.none, // Remove both horizontal and vertical gridlines
          columns: <GridColumn>[
            GridColumn(
              columnName: 'principal',
              label: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.centerLeft,
                decoration: const BoxDecoration(
                  color: Colors.deepPurple, // Set header background color
                ),
                child: const Text(
                  'Principal',
                  style: TextStyle(fontSize: 12, color: Colors.white), // Set text style for the header
                ),
              ),
            ),
            GridColumn(
              columnName: 'tons',
              label: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.deepPurple, // Set header background color
                ),
                child: const Text(
                  'Tons/Litros',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
            GridColumn(
              columnName: 'valor',
              label: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.deepPurple, // Set header background color
                ),
                child: const Text(
                  'Valor',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
            GridColumn(
              columnName: 'contribuicao',
              label: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.deepPurple, // Set header background color
                ),
                child: const Text(
                  'Contribuicao',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
          ],
          columnWidthMode: ColumnWidthMode.fill, // Ensure columns fill the available width
          allowColumnsResizing: true, // Allow resizing if needed
        );
      },
    );
  }
}

class PrincipalTableDataSource extends DataGridSource {
  List<DataGridRow> _principalDataGridRows = [];

  PrincipalTableDataSource(List<PrincipalTableData> principalData) {
    // Sort data by 'valor' field (y) in descending order
    principalData.sort((a, b) => b.valor.compareTo(a.valor));

    _principalDataGridRows = principalData
        .map<DataGridRow>((data) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'descricao', value: data.descricao),
      DataGridCell<String>(columnName: 'tons', value: data.tons.round().toString()),
      DataGridCell<String>(columnName: 'valor', value: Utils.roundToDecimal(data.valor / 1000000, 1).toString()),
      DataGridCell<String>(columnName: 'contribuicao', value: '${data.percentual.toStringAsFixed(0)}%'),
    ]))
        .toList();
  }

  @override
  List<DataGridRow> get rows => _principalDataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    int rowIndex = _principalDataGridRows.indexOf(row);

    // Alternating row colors
    Color backgroundColor = rowIndex % 2 == 0
        ? Colors.grey.shade100 // Light grey color for even rows
        : Colors.white; // White color for odd rows

    return DataGridRowAdapter(
      color: backgroundColor, // Set the alternating background color
      cells: [
        Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text(
            row.getCells()[0].value.toString(),
            style: const TextStyle(fontSize: 11),
          ), // Descricao
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(
            row.getCells()[1].value.toString(),
            style: const TextStyle(fontSize: 11),
          ), // Tons
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(
            row.getCells()[2].value.toString(),
            style: const TextStyle(fontSize: 11),
          ), // Valor
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(
            row.getCells()[3].value.toString(),
            style: const TextStyle(fontSize: 11),
          ), // Contribuicao
        ),
      ],
    );
  }
}
