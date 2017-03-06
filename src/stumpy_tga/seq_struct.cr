module StumpyTGA
  macro seq_struct(name, **fields)
    struct {{name}}
      {% for name, type in fields %}
        property {{name}} : {{type}}
      {% end %}

      def initialize({{fields.keys.map{ |x| "@#{x}" }.join(",").id}})
      end

      def self.from_io(io : IO, bf)
        {% for k, t in fields%}
          {{k}} = io.read_bytes({{t}}, bf)
        {% end %}
        new(
          {{fields.keys.join(",").id}}
        )
      end

      def to_io(io : IO, bf)
        {% for k, t in fields%}
          io.write_bytes {{k}}, bf
        {% end %}
      end
    end
  end
end
