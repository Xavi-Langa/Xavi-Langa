import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:daily_sales/models/sucursal_chart_data.dart'; // Import ChartData model
import 'package:daily_sales/services/firestore_service.dart';

import '../utils/utils.dart'; // Firestore service

class SucursalChartPage extends StatelessWidget {
  const SucursalChartPage({super.key});

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

        final sucursalData =
            snapshot.data!['sucursalData'] as List<SucursalChartData>;
        final totalValue = snapshot.data!['totalValue'].toString();
        final totalValueToday = snapshot.data!['totalValueToday'];
        final date = snapshot.data!['date'] as String?;

        return SfCircularChart(
          tooltipBehavior: TooltipBehavior(
            enable: true,
            duration: 5000,
            //animationDuration: 500,
            textStyle: const TextStyle(
              fontSize: 10, // Set the desired font size here
              fontWeight: FontWeight.normal, // Optional: customize font weight
              color: Colors.white, // Optional: customize text color
            ),
          ),
          onTooltipRender: (TooltipArgs args) {
            final SucursalChartData data =
                sucursalData[args.pointIndex!.toInt()];

            String percentualText = data.percentual.toStringAsFixed(0);
            String dateTimeText = data.date;

            args.text = 'Sucu. = ${data.sucursal}'
                '\nTotal  = ${Utils.formatNumberWithCommas(data.valor.toInt())}'
                '\nHoje  = ${Utils.formatNumberWithCommas(data.valor_do_dia.toInt())}'
                '\nCont. = $percentualText%'
                '\nData  = $dateTimeText';
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
                  Text('Hoje: $totalValueToday', style: const TextStyle(fontSize: 10)),
                  if (date != null)
                    Text(date, style: const TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ],
          series: <CircularSeries<SucursalChartData, String>>[
            DoughnutSeries<SucursalChartData, String>(
              dataSource: sucursalData,
              xValueMapper: (SucursalChartData data, _) => data.sucursal,
              yValueMapper: (SucursalChartData data, _) =>
                  Utils.roundToDecimal(data.valor / 1000000, 1),
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
