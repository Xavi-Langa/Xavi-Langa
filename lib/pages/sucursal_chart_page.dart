import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:daily_sales/models/sucursal_chart_data.dart'; // Import ChartData model
import 'package:daily_sales/services/firestore_service.dart'; // Firestore service

class SucursalChartPage extends StatelessWidget {
  const SucursalChartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: FirestoreService().getSucursalChartData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!['sucursalData'].isEmpty) {
          return const Center(child: Text('No data available'));
        }

        final sucursalData = snapshot.data!['sucursalData'] as List<SucursalChartData>;
        final totalValue = snapshot.data!['totalValue'] as String;
        final date = snapshot.data!['date'] as String?;

        return SfCircularChart(
          tooltipBehavior: TooltipBehavior(
            enable: true,
            textStyle: const TextStyle(
              fontSize: 10, // Set the desired font size here
              fontWeight: FontWeight.normal, // Optional: customize font weight
              color: Colors.white, // Optional: customize text color
            ),
          ),
          onTooltipRender: (TooltipArgs args) {
            final SucursalChartData data = sucursalData[args.pointIndex!.toInt()];

            String percentualText = data.percentual.toStringAsFixed(0);
            String dateTimeText = data.date;

            args.text =
                'Sucu. = ${data.x}\nValor = ${data.y} M\nCont. = $percentualText%\nData  = $dateTimeText';
          },
          legend: const Legend(
            isVisible: true,
            //toggleSeriesVisibility: true,
            overflowMode: LegendItemOverflowMode.wrap,
            position: LegendPosition.top,
            textStyle: TextStyle(fontSize: 11),
            //itemPadding: 7,
          ),
          annotations: <CircularChartAnnotation>[
            CircularChartAnnotation(
              widget: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$totalValue M', style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 10),
                  Container(height: 1, width: 115, color: Colors.black),
                  const SizedBox(height: 5),
                  if (date != null)
                    Text(date, style: const TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ],
          series: <CircularSeries<SucursalChartData, String>>[
            DoughnutSeries<SucursalChartData, String>(
              dataSource: sucursalData,
              xValueMapper: (SucursalChartData data, _) => data.x,
              yValueMapper: (SucursalChartData data, _) => data.y,
              innerRadius: '65%',
              dataLabelSettings: const DataLabelSettings(
                  showZeroValue: false,
                  isVisible: true,
                  textStyle: TextStyle(fontSize: 11)),
              explode: true,
              name: 'Valor',
              legendIconType: LegendIconType.circle,
            ),
          ],
        );
      },
    );
  }
}
