import 'package:twinned_api/api/twinned.swagger.dart';

class ConditionModel {
  final Condition condition;
  const ConditionModel({required this.condition});

  static String explain(Condition c) {
    switch (c.condition) {
      case ConditionCondition.lt:
        return '${c.name} {${c.field} < ${c.$value}}';
      case ConditionCondition.lte:
        return '${c.name} {${c.field} <= ${c.$value}}';
      case ConditionCondition.gt:
        return '${c.name} {${c.field} > ${c.$value}}';
      case ConditionCondition.gte:
        return '${c.name} {${c.field} >= ${c.$value}}';
      case ConditionCondition.eq:
        return '${c.name} {${c.field} == ${c.$value}}';
      case ConditionCondition.neq:
        return '${c.name} {${c.field} != ${c.$value}}';
      case ConditionCondition.between:
        return '${c.name} {${c.field} range [${c.leftValue} - ${c.rightValue}]}';
      case ConditionCondition.nbetween:
        return '${c.name} {${c.field} !range [${c.leftValue} - ${c.rightValue}]}';
      case ConditionCondition.contains:
        return "${c.name} {${c.field} in [${c.values!.join(',')}]}";
      case ConditionCondition.ncontains:
        return "${c.name} {${c.field} !in [${c.values!.join(',')}]}";
      case ConditionCondition.swaggerGeneratedUnknown:
    }

    return '';
  }

  @override
  String toString() => condition.name;
}
