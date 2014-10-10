require 'json-schema'

module LiveStatus
    class QuerystringBuilder
        @@schema = {
            'type' => 'object',
            'required' => ['table','columns'],
            'properties' => {
                'table' => { 'type' => 'string', 'minLength' => 1},
                'columns' => {
                    'type'        => 'array',
                    'items'       => { 'type' => 'string', 'minLength' => 1 },
                    'minItems'    => 1,
                    'uniqueItems' => true
                },
                'filters' => {
                    'type'        => 'array',
                    'items'       => {
                        'type'       => 'object',
                        'oneOf'      => [
                            { '$ref' => '#/definitions/filterFilter' },
                            { '$ref' => '#/definitions/filterAnd'    },
                            { '$ref' => '#/definitions/filterOr'     },
                            { '$ref' => '#/definitions/filterNegate' }
                        ]
                    },
                    'minItems'    => 1,
                    'uniqueItems' => true
                },
                'socket' => { 'type' => 'string', 'minLength' => 1 }
            },
            'definitions' => {
                'filterFilter'   => {
                    'type'       => 'object',
                    'required'   => ['column','op','value'],
                    'properties' => {
                        'column' => { 'type' => 'string', 'minLength' => 1 },
                        'op'     => { 'type' => 'string', 'minLength' => 1 },
                        'value'  => { 'type' => 'string', 'minLength' => 1 }
                    }
                },
                'filterAnd'      => {
                    'type'       => 'object',
                    'required'   => ['and'],
                    'properties' => {
                        'and'    => { 'type' => 'integer', 'minimum' => 2 }
                    }
                },
                'filterOr'       => {
                    'type'       => 'object',
                    'required'   => ['or'],
                    'properties' => {
                        'or'     => { 'type' => 'integer', 'minimum' => 2 }
                    }
                },
                'filterNegate'   => {
                    'type'       => 'object',
                    'required'   => ['negate'],
                    'properties' => {
                        'negate' => { 'type' => 'boolean' }
                    }
                }
            }
        }

        # json_data must have been previously deserialised
        def initialize json_data
            @json_data = json_data
        end

        def validation_errors
            JSON::Validator.fully_validate @@schema, @json_data
        end

        def build
            q  = "GET #{@json_data['table']} \n" +
                 "Columns: #{@json_data['columns'].join ' '}\n" +
                 "ColumnHeaders: on\n"
            if @json_data.has_key? 'filters'
                @json_data['filters'].each do |f|
                    case f.keys[0]
                    when 'and'
                        q += "And: #{f['and']}\n"
                    when 'or'
                        q += "Or: #{f['or']}\n"
                    when 'negate'
                        next unless f['negate']
                        q += "Negate:\n"
                    else
                        q += "Filter: #{f['column']} #{f['op']} #{f['value']}\n"
                    end
                end
            end
            q += "\n"
            q
        end
    end
end
