import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:daily_sales/services/firestore_service.dart'; // Your FirestoreService
import 'package:daily_sales/utils/utils.dart';
import '../models/produto_table_data.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class ProdutoTablePage extends StatefulWidget {
  @override
  _ProdutoTablePageState createState() => _ProdutoTablePageState();
}

class _ProdutoTablePageState extends State<ProdutoTablePage> {
  late ProdutoTableDataSource produtoDataSource;
  String selectedSucursal = 'Total'; // Default selection

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Radio Buttons for filtering by sucursal
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRadioButton('Total'),
            _buildRadioButton('Maputo'),
            _buildRadioButton('Beira'),
            _buildRadioButton('Nampula'),
            _buildRadioButton('Tete'),
            _buildRadioButton('Pemba'),
          ],
        ),
        Expanded(
          child: StreamBuilder<List<ProdutoTableData>>(
            stream: FirestoreService().getProdutoTableData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error loading data'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No data available'));
              }

              // Filter the data based on the selected sucursal
              final filteredData = snapshot.data!
                  .where((data) => data.sucursal == selectedSucursal)
                  .toList();

              // Assign filtered data to the datasource
              produtoDataSource = ProdutoTableDataSource(filteredData);

              return SfDataGrid(
                key: UniqueKey(), // Ensures the DataGrid is rebuilt and refreshed properly
                headerRowHeight: 40, // Adjust this value to your desired height
                rowHeight: 40, // Adjust this value to your desired height
                source: produtoDataSource,
                gridLinesVisibility: GridLinesVisibility.none, // Remove both horizontal and vertical gridlines
                tableSummaryRows: [
                  GridTableSummaryRow(
                    color: Colors.deepPurple.shade50,
                    showSummaryInRow: true,
                    title:
                    'No. de produtos = {Count}, Total Volume = {SumQtd}, Total em Valor = {SumValor}',
                    titleColumnSpan: 4, // Span the title across the first column
                    columns: [
                      const GridSummaryColumn(
                        name: 'Count',
                        columnName: 'descricao',
                        summaryType: GridSummaryType.count,
                      ),
                      const GridSummaryColumn(
                        name: 'SumQtd',
                        columnName: 'qtd',
                        summaryType: GridSummaryType.sum,
                      ),
                      const GridSummaryColumn(
                        name: 'SumValor',
                        columnName: 'valor',
                        summaryType: GridSummaryType.sum,
                      ),
                    ],
                    position: GridTableSummaryRowPosition.top,
                  ),
                ],
                columns: <GridColumn>[
                  GridColumn(
                    columnName: 'descricao',
                    label: Container(
                      padding: const EdgeInsets.all(8.0),
                      alignment: Alignment.centerLeft,
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple, // Set header background color
                      ),
                      child: const Text(
                        'Descricao',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
                  GridColumn(
                    maximumWidth: 100, // Set maximum width for the 'qtd' column
                    columnName: 'qtd',
                    label: Container(
                      padding: const EdgeInsets.all(8.0),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple, // Set header background color
                      ),
                      child: const Text(
                        'Qtd',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
                  GridColumn(
                    maximumWidth: 100, // Set maximum width for the 'valor' column
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
                ],
                columnWidthMode: ColumnWidthMode.fill, // Ensure columns fill the available width
                allowColumnsResizing: true, // Allow resizing if needed
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRadioButton(String value) {
    return Row(
      children: [
        // Adjust the size of the Radio button
        Radio<String>(
          value: value,
          groupValue: selectedSucursal,
          onChanged: (String? newValue) {
            setState(() {
              selectedSucursal = newValue!;
            });
          },
          // Adjust size using materialTapTargetSize
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        // Adjust the text size
        Text(
          value,
          style: const TextStyle(fontSize: 10), // Smaller text size
        ),
      ],
    );
  }

}

class ProdutoTableDataSource extends DataGridSource {
  List<DataGridRow> _produtoDataGridRows = [];

  ProdutoTableDataSource(List<ProdutoTableData> produtoData) {
    // Sort data by 'valor' field (y) in descending order
    produtoData.sort((a, b) => b.valor.compareTo(a.valor));

    _produtoDataGridRows = produtoData
        .map<DataGridRow>((data) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'descricao', value: data.descricao),
      DataGridCell<double>(columnName: 'qtd', value: data.qtd),
      DataGridCell<double>(columnName: 'valor', value: data.valor),
    ]))
        .toList();
  }

  @override
  List<DataGridRow> get rows => _produtoDataGridRows;

  @override
  Widget? buildTableSummaryCellWidget(GridTableSummaryRow summaryRow, GridSummaryColumn? summaryColumn, RowColumnIndex rowColumnIndex, String summaryValue) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        summaryValue,
        style: const TextStyle(fontSize: 12, color: Colors.black),
      ),
    );
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    int rowIndex = _produtoDataGridRows.indexOf(row);

    // Alternating row colors
    Color backgroundColor = rowIndex % 2 == 0 ? Colors.grey.shade100 : Colors.white;

    return DataGridRowAdapter(
      color: backgroundColor, // Set the alternating background color
      cells: [
        Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text(
            row.getCells()[0].value.toString(),
            style: const TextStyle(fontSize: 11),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(
            Utils.formatNumberWithCommas(row.getCells()[1].value!.toInt()), // Format qtd with commas
            style: const TextStyle(fontSize: 11),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(
            Utils.formatNumberWithCommas(row.getCells()[2].value!.toInt()), // Format valor with commas
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ],
    );
  }
}
