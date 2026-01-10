import 'package:flutter_test/flutter_test.dart';
import 'package:suayed/models/teacher_model.dart';

void main() {
  group('TeacherModel', () {
    group('Constructor', () {
      test('crea instancia con todos los campos requeridos', () {
        final teacher = TeacherModel(
          id: 1,
          grade: 'Dr.',
          firstname: 'Juan',
          lastname: 'Pérez',
          email: 'jperez@unam.mx',
          picture: 'https://example.com/photo.jpg',
          mainfield: 'Psicología Clínica',
          fields: 'Terapia Cognitivo-Conductual, Neuropsicología',
          cv: 'https://example.com/cv.pdf',
        );

        expect(teacher.id, 1);
        expect(teacher.grade, 'Dr.');
        expect(teacher.firstname, 'Juan');
        expect(teacher.lastname, 'Pérez');
        expect(teacher.email, 'jperez@unam.mx');
        expect(teacher.picture, 'https://example.com/photo.jpg');
        expect(teacher.mainfield, 'Psicología Clínica');
        expect(teacher.fields, 'Terapia Cognitivo-Conductual, Neuropsicología');
        expect(teacher.cv, 'https://example.com/cv.pdf');
      });
    });

    group('fromJson', () {
      test('crea instancia válida desde JSON completo', () {
        final json = {
          'id': '123',
          'grade': 'Mtro.',
          'firstname': 'María',
          'lastname': 'García López',
          'email': 'mgarcia@unam.mx',
          'picture': 'https://suayed.iztacala.unam.mx/photos/mgarcia.jpg',
          'mainfield': 'Psicología Educativa',
          'fields': 'Desarrollo Infantil, Aprendizaje',
          'cv': 'https://suayed.iztacala.unam.mx/cv/mgarcia.pdf',
        };

        final teacher = TeacherModel.fromJson(json);

        expect(teacher.id, 123);
        expect(teacher.grade, 'Mtro.');
        expect(teacher.firstname, 'María');
        expect(teacher.lastname, 'García López');
        expect(teacher.email, 'mgarcia@unam.mx');
        expect(teacher.picture, 'https://suayed.iztacala.unam.mx/photos/mgarcia.jpg');
        expect(teacher.mainfield, 'Psicología Educativa');
        expect(teacher.fields, 'Desarrollo Infantil, Aprendizaje');
        expect(teacher.cv, 'https://suayed.iztacala.unam.mx/cv/mgarcia.pdf');
      });

      test('parsea id como String numérico', () {
        final json = {
          'id': '456',
          'grade': 'Dr.',
          'firstname': 'Test',
          'lastname': 'User',
          'email': 'test@test.com',
          'picture': '',
          'mainfield': '',
          'fields': '',
          'cv': '',
        };

        final teacher = TeacherModel.fromJson(json);

        expect(teacher.id, 456);
      });

      test('lanza FormatException si id no es numérico', () {
        final json = {
          'id': 'invalid',
          'grade': 'Dr.',
          'firstname': 'Test',
          'lastname': 'User',
          'email': 'test@test.com',
          'picture': '',
          'mainfield': '',
          'fields': '',
          'cv': '',
        };

        expect(
          () => TeacherModel.fromJson(json),
          throwsA(isA<FormatException>()),
        );
      });

      test('maneja nombres con caracteres especiales', () {
        final json = {
          'id': '1',
          'grade': 'Dra.',
          'firstname': 'María José',
          'lastname': "O'Brien García-Martínez",
          'email': 'mjose@unam.mx',
          'picture': '',
          'mainfield': '',
          'fields': '',
          'cv': '',
        };

        final teacher = TeacherModel.fromJson(json);

        expect(teacher.firstname, 'María José');
        expect(teacher.lastname, "O'Brien García-Martínez");
      });

      test('maneja campos vacíos', () {
        final json = {
          'id': '1',
          'grade': '',
          'firstname': '',
          'lastname': '',
          'email': '',
          'picture': '',
          'mainfield': '',
          'fields': '',
          'cv': '',
        };

        final teacher = TeacherModel.fromJson(json);

        expect(teacher.grade, '');
        expect(teacher.firstname, '');
        expect(teacher.lastname, '');
        expect(teacher.email, '');
        expect(teacher.picture, '');
        expect(teacher.mainfield, '');
        expect(teacher.fields, '');
        expect(teacher.cv, '');
      });

      test('maneja grados académicos comunes', () {
        final grades = ['Lic.', 'Mtro.', 'Mtra.', 'Dr.', 'Dra.', 'Psic.', 'M.C.', 'Ph.D.'];

        for (final grade in grades) {
          final json = {
            'id': '1',
            'grade': grade,
            'firstname': 'Test',
            'lastname': 'User',
            'email': 'test@test.com',
            'picture': '',
            'mainfield': '',
            'fields': '',
            'cv': '',
          };

          final teacher = TeacherModel.fromJson(json);
          expect(teacher.grade, grade);
        }
      });
    });

    group('toJson', () {
      test('serializa a JSON válido', () {
        final teacher = TeacherModel(
          id: 789,
          grade: 'Dr.',
          firstname: 'Carlos',
          lastname: 'Hernández',
          email: 'chernandez@unam.mx',
          picture: 'https://example.com/carlos.jpg',
          mainfield: 'Neurociencias',
          fields: 'Neuropsicología, Cognición',
          cv: 'https://example.com/cv_carlos.pdf',
        );

        final json = teacher.toJson();

        expect(json['id'], 789);
        expect(json['grade'], 'Dr.');
        expect(json['firstname'], 'Carlos');
        expect(json['lastname'], 'Hernández');
        expect(json['email'], 'chernandez@unam.mx');
        expect(json['picture'], 'https://example.com/carlos.jpg');
        expect(json['mainfield'], 'Neurociencias');
        expect(json['fields'], 'Neuropsicología, Cognición');
        expect(json['cv'], 'https://example.com/cv_carlos.pdf');
      });

      test('genera JSON con todas las claves esperadas', () {
        final teacher = TeacherModel(
          id: 1,
          grade: 'Test',
          firstname: 'Test',
          lastname: 'Test',
          email: 'test@test.com',
          picture: '',
          mainfield: '',
          fields: '',
          cv: '',
        );

        final json = teacher.toJson();

        expect(json.keys, containsAll([
          'id',
          'grade',
          'firstname',
          'lastname',
          'email',
          'picture',
          'mainfield',
          'fields',
          'cv',
        ]));
        expect(json.length, 9);
      });
    });

    group('fromJson y toJson reversibilidad', () {
      test('son reversibles', () {
        final originalJson = {
          'id': '42',
          'grade': 'Dra.',
          'firstname': 'Ana',
          'lastname': 'Martínez',
          'email': 'amartinez@unam.mx',
          'picture': 'https://example.com/ana.jpg',
          'mainfield': 'Psicología Social',
          'fields': 'Grupos, Comunidad',
          'cv': 'https://example.com/ana_cv.pdf',
        };

        final teacher = TeacherModel.fromJson(originalJson);
        final resultJson = teacher.toJson();

        // Nota: id se convierte de String a int
        expect(resultJson['id'], int.parse(originalJson['id'] as String));
        expect(resultJson['grade'], originalJson['grade']);
        expect(resultJson['firstname'], originalJson['firstname']);
        expect(resultJson['lastname'], originalJson['lastname']);
        expect(resultJson['email'], originalJson['email']);
        expect(resultJson['picture'], originalJson['picture']);
        expect(resultJson['mainfield'], originalJson['mainfield']);
        expect(resultJson['fields'], originalJson['fields']);
        expect(resultJson['cv'], originalJson['cv']);
      });

      test('múltiples ciclos de serialización mantienen datos', () {
        final teacher1 = TeacherModel(
          id: 100,
          grade: 'Mtro.',
          firstname: 'Roberto',
          lastname: 'Sánchez',
          email: 'rsanchez@unam.mx',
          picture: 'photo.jpg',
          mainfield: 'Clínica',
          fields: 'Terapia',
          cv: 'cv.pdf',
        );

        // Ciclo 1
        final json1 = teacher1.toJson();
        json1['id'] = json1['id'].toString(); // Simular JSON de API
        final teacher2 = TeacherModel.fromJson(json1);

        // Ciclo 2
        final json2 = teacher2.toJson();
        json2['id'] = json2['id'].toString();
        final teacher3 = TeacherModel.fromJson(json2);

        expect(teacher3.id, teacher1.id);
        expect(teacher3.firstname, teacher1.firstname);
        expect(teacher3.lastname, teacher1.lastname);
        expect(teacher3.email, teacher1.email);
      });
    });

    group('Casos edge', () {
      test('maneja id con ceros a la izquierda', () {
        final json = {
          'id': '007',
          'grade': 'Dr.',
          'firstname': 'Test',
          'lastname': 'User',
          'email': 'test@test.com',
          'picture': '',
          'mainfield': '',
          'fields': '',
          'cv': '',
        };

        final teacher = TeacherModel.fromJson(json);

        expect(teacher.id, 7);
      });

      test('maneja URLs con caracteres especiales', () {
        final json = {
          'id': '1',
          'grade': 'Dr.',
          'firstname': 'Test',
          'lastname': 'User',
          'email': 'test@test.com',
          'picture': 'https://example.com/photos/user%20name.jpg?v=1&size=large',
          'mainfield': '',
          'fields': '',
          'cv': 'https://example.com/cv/file%20name.pdf#page=1',
        };

        final teacher = TeacherModel.fromJson(json);

        expect(teacher.picture, 'https://example.com/photos/user%20name.jpg?v=1&size=large');
        expect(teacher.cv, 'https://example.com/cv/file%20name.pdf#page=1');
      });

      test('maneja fields con múltiples áreas separadas por coma', () {
        final json = {
          'id': '1',
          'grade': 'Dr.',
          'firstname': 'Test',
          'lastname': 'User',
          'email': 'test@test.com',
          'picture': '',
          'mainfield': 'Área Principal',
          'fields': 'Campo 1, Campo 2, Campo 3, Campo 4, Campo 5',
          'cv': '',
        };

        final teacher = TeacherModel.fromJson(json);

        expect(teacher.fields, 'Campo 1, Campo 2, Campo 3, Campo 4, Campo 5');
        expect(teacher.fields.split(', ').length, 5);
      });

      test('maneja emails con formato especial', () {
        final json = {
          'id': '1',
          'grade': 'Dr.',
          'firstname': 'Test',
          'lastname': 'User',
          'email': 'user.name+tag@subdomain.unam.mx',
          'picture': '',
          'mainfield': '',
          'fields': '',
          'cv': '',
        };

        final teacher = TeacherModel.fromJson(json);

        expect(teacher.email, 'user.name+tag@subdomain.unam.mx');
      });

      test('maneja nombres muy largos', () {
        final json = {
          'id': '1',
          'grade': 'Dr.',
          'firstname': 'Juan Carlos Alberto',
          'lastname': 'García Martínez de la Torre Blanca',
          'email': 'jcgarcia@unam.mx',
          'picture': '',
          'mainfield': '',
          'fields': '',
          'cv': '',
        };

        final teacher = TeacherModel.fromJson(json);

        expect(teacher.firstname, 'Juan Carlos Alberto');
        expect(teacher.lastname, 'García Martínez de la Torre Blanca');
      });
    });
  });
}
