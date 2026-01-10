import 'package:flutter_test/flutter_test.dart';
import 'package:suayed/models/area_model.dart';

void main() {
  group('AreaModel', () {
    group('Constructor', () {
      test('crea instancia con todos los campos requeridos', () {
        final area = AreaModel(
          id: 1,
          departmentName: 'Departamento de Prueba',
          title: 'Título del Área',
          agent: 'Agente Responsable',
          departmentEmail: 'depto@example.com',
          personalEmail: 'personal@example.com',
          detail: 'Descripción detallada del área',
        );

        expect(area.id, 1);
        expect(area.departmentName, 'Departamento de Prueba');
        expect(area.title, 'Título del Área');
        expect(area.agent, 'Agente Responsable');
        expect(area.departmentEmail, 'depto@example.com');
        expect(area.personalEmail, 'personal@example.com');
        expect(area.detail, 'Descripción detallada del área');
      });
    });

    group('fromJson', () {
      test('crea instancia válida desde JSON completo', () {
        final json = {
          'id': '123',
          'department_name': 'Psicología Clínica',
          'title': 'Coordinación de Clínica',
          'agent': 'Dr. Juan Pérez',
          'department_email': 'clinica@unam.mx',
          'personal_email': 'jperez@unam.mx',
          'detail': 'Área dedicada a la formación clínica',
        };

        final area = AreaModel.fromJson(json);

        expect(area.id, 123);
        expect(area.departmentName, 'Psicología Clínica');
        expect(area.title, 'Coordinación de Clínica');
        expect(area.agent, 'Dr. Juan Pérez');
        expect(area.departmentEmail, 'clinica@unam.mx');
        expect(area.personalEmail, 'jperez@unam.mx');
        expect(area.detail, 'Área dedicada a la formación clínica');
      });

      test('parsea id como String numérico', () {
        final json = {
          'id': '456',
          'department_name': 'Test',
          'title': 'Test',
          'agent': 'Test',
          'department_email': 'test@test.com',
          'personal_email': 'test@test.com',
          'detail': 'Test',
        };

        final area = AreaModel.fromJson(json);

        expect(area.id, 456);
      });

      test('lanza FormatException si id no es numérico', () {
        final json = {
          'id': 'abc',
          'department_name': 'Test',
          'title': 'Test',
          'agent': 'Test',
          'department_email': 'test@test.com',
          'personal_email': 'test@test.com',
          'detail': 'Test',
        };

        expect(
          () => AreaModel.fromJson(json),
          throwsA(isA<FormatException>()),
        );
      });

      test('maneja campos con caracteres especiales', () {
        final json = {
          'id': '1',
          'department_name': 'Área de Investigación y Desarrollo',
          'title': 'Coordinación de I+D',
          'agent': 'Dra. María José García',
          'department_email': 'i+d@unam.mx',
          'personal_email': 'mj.garcia@unam.mx',
          'detail': 'Área con énfasis en investigación científica & desarrollo',
        };

        final area = AreaModel.fromJson(json);

        expect(area.departmentName, 'Área de Investigación y Desarrollo');
        expect(area.agent, 'Dra. María José García');
      });

      test('maneja campos vacíos', () {
        final json = {
          'id': '1',
          'department_name': '',
          'title': '',
          'agent': '',
          'department_email': '',
          'personal_email': '',
          'detail': '',
        };

        final area = AreaModel.fromJson(json);

        expect(area.departmentName, '');
        expect(area.title, '');
        expect(area.agent, '');
        expect(area.departmentEmail, '');
        expect(area.personalEmail, '');
        expect(area.detail, '');
      });
    });

    group('toJson', () {
      test('serializa a JSON válido', () {
        final area = AreaModel(
          id: 789,
          departmentName: 'Departamento Test',
          title: 'Título Test',
          agent: 'Agente Test',
          departmentEmail: 'depto@test.com',
          personalEmail: 'personal@test.com',
          detail: 'Detalle Test',
        );

        final json = area.toJson();

        expect(json['id'], 789);
        expect(json['department_name'], 'Departamento Test');
        expect(json['title'], 'Título Test');
        expect(json['agent'], 'Agente Test');
        expect(json['department_email'], 'depto@test.com');
        expect(json['personal_email'], 'personal@test.com');
        expect(json['detail'], 'Detalle Test');
      });

      test('genera JSON con todas las claves esperadas', () {
        final area = AreaModel(
          id: 1,
          departmentName: 'Test',
          title: 'Test',
          agent: 'Test',
          departmentEmail: 'test@test.com',
          personalEmail: 'test@test.com',
          detail: 'Test',
        );

        final json = area.toJson();

        expect(json.keys, containsAll([
          'id',
          'department_name',
          'title',
          'agent',
          'department_email',
          'personal_email',
          'detail',
        ]));
        expect(json.length, 7);
      });
    });

    group('fromJson y toJson reversibilidad', () {
      test('son reversibles', () {
        final originalJson = {
          'id': '42',
          'department_name': 'Psicología Social',
          'title': 'Coordinación Social',
          'agent': 'Mtro. Carlos López',
          'department_email': 'social@unam.mx',
          'personal_email': 'clopez@unam.mx',
          'detail': 'Área de psicología social y comunitaria',
        };

        final area = AreaModel.fromJson(originalJson);
        final resultJson = area.toJson();

        // Nota: id se convierte de String a int
        expect(resultJson['id'], int.parse(originalJson['id'] as String));
        expect(resultJson['department_name'], originalJson['department_name']);
        expect(resultJson['title'], originalJson['title']);
        expect(resultJson['agent'], originalJson['agent']);
        expect(resultJson['department_email'], originalJson['department_email']);
        expect(resultJson['personal_email'], originalJson['personal_email']);
        expect(resultJson['detail'], originalJson['detail']);
      });

      test('múltiples ciclos de serialización mantienen datos', () {
        final area1 = AreaModel(
          id: 100,
          departmentName: 'Original',
          title: 'Title',
          agent: 'Agent',
          departmentEmail: 'email@test.com',
          personalEmail: 'personal@test.com',
          detail: 'Detail',
        );

        // Ciclo 1
        final json1 = area1.toJson();
        json1['id'] = json1['id'].toString(); // Simular JSON de API
        final area2 = AreaModel.fromJson(json1);

        // Ciclo 2
        final json2 = area2.toJson();
        json2['id'] = json2['id'].toString();
        final area3 = AreaModel.fromJson(json2);

        expect(area3.id, area1.id);
        expect(area3.departmentName, area1.departmentName);
        expect(area3.title, area1.title);
      });
    });

    group('Casos edge', () {
      test('maneja id con ceros a la izquierda', () {
        final json = {
          'id': '007',
          'department_name': 'Test',
          'title': 'Test',
          'agent': 'Test',
          'department_email': 'test@test.com',
          'personal_email': 'test@test.com',
          'detail': 'Test',
        };

        final area = AreaModel.fromJson(json);

        expect(area.id, 7);
      });

      test('maneja id negativo', () {
        final json = {
          'id': '-1',
          'department_name': 'Test',
          'title': 'Test',
          'agent': 'Test',
          'department_email': 'test@test.com',
          'personal_email': 'test@test.com',
          'detail': 'Test',
        };

        final area = AreaModel.fromJson(json);

        expect(area.id, -1);
      });

      test('maneja emails con formato especial', () {
        final json = {
          'id': '1',
          'department_name': 'Test',
          'title': 'Test',
          'agent': 'Test',
          'department_email': 'user+tag@subdomain.domain.com',
          'personal_email': 'first.last@example.co.uk',
          'detail': 'Test',
        };

        final area = AreaModel.fromJson(json);

        expect(area.departmentEmail, 'user+tag@subdomain.domain.com');
        expect(area.personalEmail, 'first.last@example.co.uk');
      });

      test('maneja detail con HTML', () {
        final json = {
          'id': '1',
          'department_name': 'Test',
          'title': 'Test',
          'agent': 'Test',
          'department_email': 'test@test.com',
          'personal_email': 'test@test.com',
          'detail': '<p>Descripción con <strong>HTML</strong></p>',
        };

        final area = AreaModel.fromJson(json);

        expect(area.detail, '<p>Descripción con <strong>HTML</strong></p>');
      });
    });
  });
}
