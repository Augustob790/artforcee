// lib/widgets/forms/field_widget_factory.dart

// ... imports

import 'package:flutter/material.dart';

import '../../controllers/controllers.dart';
import '../../models/models.dart' as model;
import 'forms.dart';

class FieldWidgetFactory {
  Widget createWidget(model.FormField field, FormController controller) {
    switch (field.type) {
      case model.FieldType.text:
        return DynamicTextFieldWidget(field: field as model.TextFormField, controller: controller);
      case model.FieldType.number:
        return DynamicNumberFieldWidget(field: field as model.NumberFormField, controller: controller);
      case model.FieldType.dropdown:
        return DynamicDropdownWidget(field: field as model.DropdownFormField, controller: controller);
      case model.FieldType.date:
        return DynamicDateFieldWidget(field: field as model.DateFormField, controller: controller);
      case model.FieldType.checkbox:
      case model.FieldType.radio:
        throw UnimplementedError('Tipo de campo ${field.type} ainda não implementado');
    }
  }
}
