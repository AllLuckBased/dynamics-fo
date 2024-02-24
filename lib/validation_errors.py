errors = [
    { 'severity': 2, 'error': 'Enum value not in allowed values!',
        'log': lambda columnName, rows, rejected_values, company, entity_name: 
            f"ERROR: Some values in {columnName} does not represent a valid position in the enum:\n" +
            f"Following values were rejected: {rejected_values}\n" + 
            f"{f'Row Indices: {rows}\n' if rows else ''}" +
            f"{f'Legal Entity: {company}\n' if company else ''}" +
            f"{f'Entity: {entity_name}\n' if entity_name else ''}",
    },
]

class ValidationErrors:
    def __init__(self, severity, error):
        self.severity = severity
        self.error = error

class NoValidDataError(ValidationErrors):
    def __init__(self, entity_name=None):
        super().__init__(3, 'Every row was invalidated!!')
        self.entity_name = entity_name

    def shortLog(self):
        return f"True"

    def log(self):
        return f"FATAL: No valid data row was found for importing into Dynamics.\n" +\
            f"{f'Entity Name: {self.entity_name}\n' if self.entity_name else ''}"
    
class MissingColumnError(ValidationErrors):
    def __init__(self, columnName, entity_name=None):
        super().__init__(3, 'Mandatory column absent from data!!')
        self.columnName = columnName
        self.entity_name = entity_name
    
    def shortLog(self):
        return f"Column: {self.columnName}"

    def log(self):
        return f"FATAL: Mandatory column '{self.columnName}' was missing from the data.\n" + \
               f"{f'Entity Name: {self.entity_name}\n' if self.entity_name else ''}"

class DataTypeError(ValidationErrors):
    def __init__(self, columnName, entity_name=None):
        super().__init__(3, 'Column data type mismatch!!')
        self.columnName = columnName
        self.entity_name = entity_name
    
    def shortLog(self):
        return f"Column: {self.columnName}"
    
    def log(self):
        return f"FATAL: Data found in the column {self.columnName} is not of proper type" + \
               f"{f'Entity Name: {self.entity_name}\n' if self.entity_name else ''}"


class MissingDataError(ValidationErrors):
    def __init__(self, columnName, rows, company=None, entity_name=None):
        super().__init__(2, 'Mandatory column has some missing data!')
        self.columnName = columnName
        self.rows = rows
        self.company = company
        self.entity_name = entity_name
    
    def shortLog(self):
        return f"Column: {self.columnName}, Empty rows: {self.rows}"
    
    def log(self):
        return f"ERROR: Some rows were empty in '{self.columnName}' which is mandatory and cannot be empty:\n" + \
               f"{f'Row Indices: {self.rows}\n' if self.rows else ''}" + \
               f"{f'Legal Entity: {self.company}\n' if self.company else ''}" + \
               f"{f'Entity Name: {self.entity_name}\n' if self.entity_name else ''}"

class DataLossError(ValidationErrors):
    def __init__(self, columnName, size, grouped_lost_values, seen_truncated_value, rows, company=None, entity_name=None):
        super().__init__(2, 'Data loss on string truncation!')
        self.columnName = columnName
        self.size = size
        self.grouped_lost_values = grouped_lost_values
        self.seen_truncated_value = seen_truncated_value
        self.rows = rows
        self.company = company
        self.entity_name = entity_name
    
    def shortLog(self):
        return f"Column: {self.columnName}, Max: {self.size} Loss: {self.grouped_lost_values}"

    def log(self):
        return f"ERROR: Data loss when '{self.columnName}' was truncated to the max allowed size of: {self.size}:\n" + \
               f"{self.grouped_lost_values + [self.seen_truncated_value]} all get mapped to {self.seen_truncated_value}\n" + \
               f"{f'Row Indices: {self.rows}\n' if self.rows else ''}" + \
               f"{f'Legal Entity: {self.company}\n' if self.company else ''}" + \
               f"{f'Entity: {self.entity_name}\n' if self.entity_name else ''}"

class StringSizeError(ValidationErrors):
    def __init__(self, columnName, size, values, rows, company=None, entity_name=None):
        super().__init__(1, 'String exceeds allowed size.')
        self.columnName = columnName
        self.size = size
        self.values = values
        self.rows = rows
        self.company = company
        self.entity_name = entity_name

    def shortLog(self):
        return f"Column: {self.columnName}, Max: {self.size}, Errors: {self.values}"

    def log(self):
        return f"WARN: Strings exceeded allowed size of {self.size} in '{self.columnName}':\n" + \
               f"Following values exceeded the allowed size: {self.values}\n" + \
               f"{f'Row Indices: {self.rows}\n' if self.rows else ''}" + \
               f"{f'Legal Entity: {self.company}\n' if self.company else ''}" + \
               f"{f'Entity: {self.entity_name}\n' if self.entity_name else ''}"

class DuplicateRowsError(ValidationErrors):
    def __init__(self, index_columns, index, rows, company=None, entity_name=None):
        super().__init__(1, 'Duplicate rows.')
        self.index_columns = index_columns
        self.index = index
        self.rows = rows
        self.company = company
        self.entity_name = entity_name
    
    def shortLog(self):
        return f"Key: ({self.index_columns}), Duplicates: {self.rows}"

    def log(self):
        return f"WARN: Duplicate enties observed in unique index ({self.index_columns}).\n" + \
               f"Duplicated entry index value(s): {self.index}\n" + \
               f"{f'Row Indices: {self.rows}\n' if self.rows else ''}" + \
               f"{f'Legal Entity: {self.company}\n' if self.company else ''}" + \
               f"{f'Entity: {self.entity_name}\n' if self.entity_name else ''}"

class DataConflictError(ValidationErrors):
    def __init__(self, index_columns, index, rows, company=None, entity_name=None):
        super().__init__(2, 'Data conflict for index!')
        self.index_columns = index_columns
        self.index = index
        self.rows = rows
        self.company = company
        self.entity_name = entity_name
    
    def shortLog(self):
        return f"Key: ({self.index_columns}), Conflicts: {self.rows}"

    def log(self):
        return f"ERROR: Conflicting values obeserved for duplicate entries in unique index ({self.index_columns}).\n" + \
               f"Conflicting entry index value(s): {self.index}\n" + \
               f"{f'Row Indices: {self.rows}\n' if self.rows else ''}" + \
               f"{f'Legal Entity: {self.company}\n' if self.company else ''}" + \
               f"{f'Entity: {self.entity_name}\n' if self.entity_name else ''}"

class InvalidEnumPositionError(ValidationErrors):
    def __init__(self, columnName, rejected_values, rows, company=None, entity_name=None):
        super().__init__(2, 'Invalid enum position!')
        self.columnName = columnName
        self.rejected_values = rejected_values
        self.rows = rows
        self.company = company
        self.entity_name = entity_name
    
    def shortLog(self):
        return f"Column: {self.columnName}, Rejected: {self.rejected_values}"
    
    def log(self):
        return f"ERROR: Some values in {self.columnName} does not represent a valid position in the enum:\n" + \
               f"Following positions were rejected: {self.rejected_values}\n" + \
               f"{f'Row Indices: {self.rows}\n' if self.rows else ''}" + \
               f"{f'Legal Entity: {self.company}\n' if self.company else ''}" + \
               f"{f'Entity: {self.entity_name}\n' if self.entity_name else ''}"

class EnumValueError(ValidationErrors):
    def __init__(self, columnName, rejected_values, rows, company=None, entity_name=None):
        super().__init__(2, 'Enum value not in allowed values!')
        self.columnName = columnName
        self.rejected_values = rejected_values
        self.rows = rows
        self.company = company
        self.entity_name = entity_name
    
    def shortLog(self):
        return f"Column: {self.columnName}, Rejected: {self.rejected_values}"

    def log(self):
        return f"ERROR: Some values in {self.columnName} does not represent a valid position in the enum:\n" + \
               f"Following values were rejected: {self.rejected_values}\n" + \
               f"{f'Row Indices: {self.rows}\n' if self.rows else ''}" + \
               f"{f'Legal Entity: {self.company}\n' if self.company else ''}" + \
               f"{f'Entity: {self.entity_name}\n' if self.entity_name else ''}"

class SourceEntityNotFound(ValidationErrors):
    def __init__(self, columnName, relatedTable, relatedField, entity_name=None):
        super().__init__(3, 'Could not find source data entity!!')
        self.columnName = columnName
        self.relatedTable = relatedTable
        self.relatedField = relatedField
        self.entity_name = entity_name
    
    def shortLog(self):
        return f"Unknown source in {self.columnName} == {self.relatedField}.{self.relatedTable}"

    def log(self):
        return f"FATAL: Could not identify an entity which satisfies the relation on column {self.columnName}\n"+ \
            f"The column was dependent on {self.relatedField} field of {self.relatedTable} table\n" + \
            f"{f'Entity: {self.entity_name}\n' if self.entity_name else ''}"
    
class SourceEntityMissing(ValidationErrors):
    def __init__(self, columnName, sourceEntity, entity_field, entity_name=None):
        super().__init__(2, 'Source entity identified but data was missing!')
        self.columnName = columnName
        self.sourceEntity = sourceEntity
        self.entity_field = entity_field
        self.entity_name = entity_name
    
    def shortLog(self):
        return f"Matching {self.entity_field} was missing from {self.sourceEntity}"

    def log(self):
        return f"ERROR: The data for entity {self.sourceEntity} was not yet been provided.\n" + \
            f"Waiting to resolve dependency: {self.columnName} == {self.sourceEntity}.{self.entity_field}\n" + \
            f"{f'Entity: {self.entity_name}\n' if self.entity_name else ''}"
    
class KeyViolation(ValidationErrors):
    def __init__(self, columnName, rejected_values, rows, company=None, entity_name=None):
        super().__init__(2, 'Referenced value was not found!')
        self.columnName = columnName
        self.rejected_values = rejected_values
        self.rows = rows
        self.company = company
        self.entity_name = entity_name

    def shortLog(self):
        return f"Column: {self.columnName}, Rejected: {self.rejected_values}"

    def log(self):
        return f"ERROR: Some values in {self.columnName} were missing in its source data:\n" + \
               f"Following values were rejected: {self.rejected_values}\n" + \
               f"{f'Row Indices: {self.rows}\n' if self.rows else ''}" + \
               f"{f'Legal Entity: {self.company}\n' if self.company else ''}" + \
               f"{f'Entity: {self.entity_name}\n' if self.entity_name else ''}"