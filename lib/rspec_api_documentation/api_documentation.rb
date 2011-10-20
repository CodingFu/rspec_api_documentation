module RspecApiDocumentation
  class ApiDocumentation
    class << self
      delegate :configuration, :to => :RspecApiDocumentation

      def document_example(rspec_example, template)
        example = Example.new(rspec_example)
        FileUtils.mkdir_p(configuration.docs_dir.join(example.dirname))

        File.open(example.filepath(configuration.docs_dir), "w+") do |f|
          f.write(example.render(template))
        end
      end

      def index(rspec_example_group)
        example_group = ExampleGroup.new(rspec_example_group)
        File.open(configuration.docs_dir.join("index.#{configuration.private_index_extension}"), "a+") do |f|
          f.write("<h1>#{example_group.resource_name}</h1>")
          f.write("<ul>")
          example_group.documented_examples.each do |example|
            example = Example.new(example)
            link = Mustache.render(configuration.private_example_link, :link => "#{example.dirname}/#{example.filename}")
            f.write(%{<li><a href="#{link}">#{example.description}</a></li>})
          end
          f.write("</ul>")
        end

        return if example_group.public_examples.empty?

        File.open(configuration.public_docs_dir.join("index.#{configuration.public_index_extension}"), "a+") do |f|
          f.write("<h1>#{example_group.resource_name}</h1>")
          f.write("<ul>")
          example_group.public_examples.each do |example|
            example = Example.new(example)
            link = Mustache.render(configuration.public_example_link, :link => "#{example.dirname}/#{example.filename}")
            f.write(%{<li><a href="#{link}">#{example.description}</a></li>})
          end
          f.write("</ul>")
        end
      end

      def clear_docs
        puts "\tClearing out #{configuration.docs_dir}"
        puts "\tClearing out #{configuration.public_docs_dir}"

        FileUtils.rm_rf(configuration.docs_dir, :secure => true)
        FileUtils.mkdir_p(configuration.docs_dir)

        FileUtils.rm_rf(configuration.public_docs_dir, :secure => true)
        FileUtils.mkdir_p(configuration.public_docs_dir)
      end
    end
  end
end
