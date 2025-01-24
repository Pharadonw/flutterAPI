import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'car_mfr.dart'; // This file contains the CarMfr model and carMfrFromJson function.

class CarManufac extends StatefulWidget {
  const CarManufac({super.key});

  @override
  State<CarManufac> createState() => _CarManufacState();
}

class _CarManufacState extends State<CarManufac> {
  Future<CarMfr?> fetchCarManufacturers() async {
    const String baseUrl = "vpic.nhtsa.dot.gov";
    const String path = "/api/vehicles/getallmanufacturers";

    try {
      final uri = Uri.https(baseUrl, path, {"format": "json"});
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return carMfrFromJson(response.body);
      } else {
        throw Exception("Failed to fetch manufacturers. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching manufacturers: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Manufacturers"),
      ),
      body: FutureBuilder<CarMfr?>(
        future: fetchCarManufacturers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.hasData && snapshot.data != null) {
              final carMfr = snapshot.data!;
              return ListView.builder(
                itemCount: carMfr.results?.length ?? 0,
                itemBuilder: (context, index) {
                  final manufacturer = carMfr.results![index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: ListTile(
                      title: Row(
                        children: [
                          Text(
                            "#${manufacturer.mfrId ?? "N/A"}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              manufacturer.mfrName ?? "Unknown Manufacturer",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(manufacturer.country ?? "Unknown Country"),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text("No data available."));
            }
          } else {
            return const Center(child: Text("Something went wrong."));
          }
        },
      ),
    );
  }
}
