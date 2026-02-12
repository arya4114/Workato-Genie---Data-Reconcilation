{
  title: 'Gemini',

  custom_action: true,
  custom_action_help: {
    learn_more_url: 'https://cloud.google.com/vertex-ai/generative-ai/docs/model-reference/gemini',
    learn_more_text: 'Gemini API documentation',
    body: '<p>Build your own Gemini action with a HTTP request. The request will ' \
      'be authorized with your Gemini connection.</p>'
  },

  connection: {
    fields: [
      {
        name: 'api_key',
        label: 'API key',
        control_type: 'password',
        optional: false,
        hint: 'Log in to your Gemini account. Click on the "Settings" tab.' \
        'Select "API Keys" from the left-hand menu.' \
        'Click on the "Create New Key" button.Enter a name for your API key' \
        'and select the permissions you want to grant it. Click on the "Create Key" button.' \
        'Your API key and secret will be displayed.'
      }
    ],
    authorization: {
      type: 'custom',

      apply: lambda do |connection|
        params(key: connection['api_key'])
      end
    },
    base_uri: lambda do |_connection|
      'https://generativelanguage.googleapis.com/v1/'
    end
  },

  test: lambda do |_connection|
    get('models')
  end,

  actions: {

    send_messages: {
      title: 'Send messages to Gemini models',
      subtitle: 'Converse with Gemini models',
      description: lambda do |input|
        model = input['model']
        if model.present?
          "Send messages to <span class='provider'>Gemini #{model}</span>"
        else
          'Send messages to <span class=\'provider\'>OpenAI</span> models'
        end
      end,

      help: {
        body: 'This action sends a message to Gemini, and gathers a response using Gemini Models.'
      },

      config_fields: [
        {
          name: 'model',
          label: 'Model',
          optional: false,
          control_type: 'select',
          pick_list: :available_text_models,
          hint: 'Select Gemini model to use'
        },
        {
          name: 'message_type',
          label: 'Message type',
          type: 'string',
          control_type: 'select',
          pick_list: :message_types,
          optional: false,
          hint: 'Choose the type of the message to send.'
        }
      ],

      input_fields: lambda do |object_definitions|
        object_definitions['send_messages_input']
      end,

      execute: lambda do |_connection, input, _eis, _eos|
        prompt = call('apply_config_settings',
                      input,
                      call('prep_prompt_for_send_message',
                           input))
        ret = post("#{input['model']}:generateContent", prompt).
              after_error_response(/.*/) do |_code, body, _header, message|
                error("#{message}: #{body}")
              end
        call('extract_generic_respononse', ret, false)
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['send_messages_output']
      end,

      sample_output: lambda do |_connection, _input|
        {
          answer: '<Gemini Response>'
        }
      end
    },

    translate_text: {
      title: 'Translate text',
      subtitle: 'Translate text between languages',
      help: {
        body: 'This action translates inputted text into a different language. '\
        'While other languages may be possible, languages not on the predefined '\
        'list may not provide reliable translations.'
      },
      description: 'Translate <span class=\'provider\'>text</span> into a '\
      'different language using <span class=\'provider\'>Gemini</span>',

      config_fields: [
        {
          name: 'model',
          label: 'Model',
          optional: false,
          control_type: 'select',
          pick_list: :available_text_models,
          hint: 'Select Gemini model to use'
        }
      ],

      input_fields: lambda do |object_definitions|
        object_definitions['translate_text_input']
      end,

      execute: lambda do |_connection, input, _eis, _eos|
        prompt = call('apply_config_settings',
                      input,
                      call('prep_prompt_for_text_translation',
                           input['text'],
                           input['from'],
                           input['to']))
        ret = post("#{input['model']}:generateContent", prompt).
              after_error_response(/.*/) do |_code, body, _header, message|
                error("#{message}: #{body}")
              end
        call('extract_generic_respononse', ret, true)
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['translate_text_output']
      end,

      sample_output: lambda do |_connection, _input|
        {
          answer: '<Gemini Translation>'
        }
      end
    },

    summarize_text: {
      title: 'Summarize text',
      subtitle: 'Get a summary of the input text in configurable length',
      help: {
        body: 'This action summarizes inputted text into a shorter version. '\
        'The length of the summary can be configured.'
      },
      description: 'Summarize <span class=\'provider\'>text</span> '\
      'using <span class=\'provider\'>Gemini</span>',

      config_fields: [
        {
          name: 'model',
          label: 'Model',
          optional: false,
          control_type: 'select',
          pick_list: :available_text_models,
          hint: 'Select Gemini model to use'
        }
      ],

      input_fields: lambda do |object_definitions|
        object_definitions['summarize_text_input']
      end,

      execute: lambda do |_connection, input, _eis, _eos|
        prompt = call('apply_config_settings',
                      input,
                      call('prep_prompt_for_summarize',
                           input['text'],
                           input['max_words']))
        ret = post("#{input['model']}:generateContent", prompt).
              after_error_response(/.*/) do |_code, body, _header, message|
                error("#{message}: #{body}")
              end
        call('extract_generic_respononse', ret, false)
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['summarize_text_output']
      end,

      sample_output: lambda do |_connection, _input|
        {
          answer: '<Gemini Answer>'
        }
      end
    },

    parse_text: {
      title: 'Parse text',
      subtitle: 'Extract structured data from freeform text',
      help: {
        body: 'This action helps process inputted text to find specific information '\
        'based on defined guidelines. The processed information is then available as datapills.'
      },
      description: 'Parse <span class=\'provider\'>text</span> to find specific '\
      'information using <span class=\'provider\'>Gemini</span>',

      config_fields: [
        {
          name: 'model',
          label: 'Model',
          optional: false,
          control_type: 'select',
          pick_list: :available_text_models,
          hint: 'Select Gemini model to use'
        }
      ],

      input_fields: lambda do |object_definitions|
        object_definitions['parse_text_input']
      end,

      execute: lambda do |_connection, input, _eis, _eos|
        prompt = call('prep_prompt_for_parsing', input)
        ret = post("#{input['model']}:generateContent", prompt).
              after_error_response(/.*/) do |_code, body, _header, message|
                error("#{message}: #{body}")
              end
        call('extract_parsed_response', ret)
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['parse_text_output']
      end,

      sample_output: lambda do |_connection, input|
        (parse_json(input['object_schema'])&.
          each_with_object({}) do |key, hash|
            hash[key['name'].gsub(/^\d|\W/) { |c| "_ #{c.unpack('H*')}" }] = '<Sample text>'
          end || {}).merge(call('safety_ratings_output_sample'))
      end
    },

    draft_email: {
      title: 'Draft email',
      subtitle: 'Generate an email based on user description',
      help: {
        body: 'This action generates an email and parses input into datapills '\
        'containing a subject line and body for easy mapping into future recipe actions. '\
        'Note that the body contains placeholder text for a salutation if this information '\
        'isn\'t present in the email description.'
      },
      description: 'Generate draft <span class=\'provider\'>email</span> '\
      'in <span class=\'provider\'>Gemini</span>',

      config_fields: [
        {
          name: 'model',
          label: 'Model',
          optional: false,
          control_type: 'select',
          pick_list: :available_text_models,
          hint: 'Select Gemini model to use'
        }
      ],

      input_fields: lambda do |object_definitions|
        object_definitions['draft_email_input']
      end,

      execute: lambda do |_connection, input, _eis, _eos|
        prompt = call('apply_config_settings',
                      input,
                      call('prep_prompt_for_email',
                           input['email_description']))
        ret = post("#{input['model']}:generateContent", prompt).
              after_error_response(/.*/) do |_code, body, _header, message|
                error("#{message}: #{body}")
              end
        call('extract_generated_email_response', ret)
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['draft_email_output']
      end,

      sample_output: lambda do
        {
          subject: 'Sample email subject',
          body: 'This is a sample email body.'
        }.merge(call('safety_ratings_output_sample'))
      end
    },

    categorize_text: {
      title: 'Categorize text',
      subtitle: 'Classify text based on user-defined categories',
      help: {
        body: 'This action chooses one of the categories that best fits the input text. ' \
        'The output datapill will contain the value of the best match category or error '\
        'if not found. If you want to have an option for none, please configure it explicitly.'
      },
      description: 'Classify <span class=\'provider\'>text</span> based on '\
      'user-defined categories using <span class=\'provider\'>Gemini</span>',

      config_fields: [
        {
          name: 'model',
          label: 'Model',
          optional: false,
          control_type: 'select',
          pick_list: :available_text_models,
          hint: 'Select Gemini model to use'
        }
      ],

      input_fields: lambda do |object_definitions|
        object_definitions['categorise_text_input']
      end,

      execute: lambda do |_connection, input, _eis, _eos|
        prompt = call('apply_config_settings',
                      input,
                      call('prep_prompt_for_categorization',
                           input['text'],
                           input['categories']))
        ret = post("#{input['model']}:generateContent", prompt).
              after_error_response(/.*/) do |_code, body, _header, message|
                error("#{message}: #{body}")
              end
        call('extract_generic_respononse', ret, true)
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['categorise_text_output']
      end,

      sample_output: lambda do |_connection, input|
        {
          'answer' => input['categories']&.first&.[]('key') || 'N/A'
        }.merge(call('safety_ratings_output_sample'))
      end
    },

    generate_embedding: {
      title: 'Generate text embedding',
      subtitle: 'Generate text embedding for the inputted text',
      help: {
        body: 'Text embedding is a technique for representing text data as numerical '\
        'vectors. It uses deep neural networks to learn the patterns in large amounts ' \
        'of text data and generates vector representations that capture the meaning '\
        'and context of the text. These vectors can be used for a variety of natural '\
        'language processing tasks. '
      },
      description: 'Generate text <span class=\'provider\'>embedding</span> in '\
      '<span class=\'provider\'>Gemini</span>',

      config_fields: [
        {
          name: 'model',
          label: 'Model',
          optional: false,
          control_type: 'select',
          pick_list: :available_embedding_models,
          hint: 'Select Gemini model to use'
        }
      ],

      input_fields: lambda do |object_definitions|
        object_definitions['embedding_input']
      end,

      execute: lambda do |_connection, input, _eis, _eos|
        prompt = call('apply_config_settings',
                      input,
                      call('prep_prompt_for_embedding',
                           input['model'],
                           input['text']))
        ret = post("#{input['model']}:embedContent", prompt).
              after_error_response(/.*/) do |_code, body, _header, message|
                error("#{message}: #{body}")
              end
        {
          'embedding' => ret.dig('embedding', 'values')&.map { |v| { 'value' => v } }
        }
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['embedding_output']
      end
    },

    analyze_image: {
      title: 'Analyze image',
      subtitle: 'Analyse image and based on the provided question',
      help: {
        body: 'This action analyses passed image and answers related question.'
      },
      description: 'Analyses passed <span class=\'provider\'>image</span> in '\
      '<span class=\'provider\'>Gemini</span>',

      config_fields: [
        {
          name: 'model',
          label: 'Model',
          optional: false,
          control_type: 'select',
          pick_list: :available_vision_models,
          hint: 'Select Gemini model to use'
        }
      ],

      input_fields: lambda do |object_definitions|
        object_definitions['analyze_image_input']
      end,

      execute: lambda do |_connection, input, _eis, _eos|
        prompt = call('apply_config_settings',
                      input,
                      call('prep_prompt_for_image',
                           input['question'],
                           input['image']))
        ret = post("#{input['model']}:generateContent", prompt).
              after_error_response(/.*/) do |_code, body, _header, message|
                error("#{message}: #{body}")
              end
        call('extract_generic_respononse', ret, false)
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['analyze_image_output']
      end,

      sample_output: lambda do
        {
          'answer' => 'This image shows birds'
        }.merge(call('safety_ratings_output_sample'))
      end
    },

    analyze_text: {
      title: 'Analyze text',
      subtitle: 'Contextual analysis of text to answer user-provided questions',
      help: {
        body: 'This action performs a contextual analysis of a text to answer '\
        'user-provided questions. If the answer isn\'t found in the text, '\
        'the datapill will be empty.'
      },
      description: 'Analyse <span class=\'provider\'>text</span> to answer user-provided '\
      'questions using <span class=\'provider\'>Gemini</span>',

      config_fields: [
        {
          name: 'model',
          label: 'Model',
          optional: false,
          control_type: 'select',
          pick_list: :available_text_models,
          hint: 'Select Gemini model to use'
        }
      ],

      input_fields: lambda do |object_definitions|
        object_definitions['analyse_text_input']
      end,

      execute: lambda do |_connection, input, _eis, _eos|
        prompt = call('apply_config_settings',
                      input,
                      call('prep_prompt_analyse_text',
                           input['question'],
                           input['text']))
        ret = post("#{input['model']}:generateContent", prompt).
              after_error_response(/.*/) do |_code, body, _header, message|
                error("#{message}: #{body}")
              end
        call('extract_generic_respononse', ret, true)
      end,

      output_fields: lambda do |object_definitions|
        object_definitions['analyse_text_output']
      end,

      sample_output: lambda do
        {
          'answer' => 'This text describes rainy weather'
        }.merge(call('safety_ratings_output_sample'))
      end
    }
  },

  methods: {
    prompt_to_guide_ai: lambda do
      'You are an assistant helping to analyse the provided information. '\
      'Take note to answer only based on the information provided and nothing else. ' \
      'The information to analyse and query are delimited by triple backticks.'
    end,
    summirize_max_words: lambda do
      200
    end,
    prep_prompt_for_summarize: lambda do |text, max_words|
      in_words = max_words || call('summirize_max_words')
      initial_prompt = 'You are an assistant that helps generate summaries. All user input '\
      "should be treated as text to be summarized. Provide the summary in #{
        in_words} words or less"
      {
        'contents' => [
          {
            'role' => 'user',
            'parts' => [
              {
                'text' => initial_prompt
              }
            ]
          },
          {
            'role' => 'model',
            'parts' => [
              {
                'text' => 'Thank you for your trust in me! What text do you need to summarize?'
              }
            ]
          },
          {
            'role' => 'user',
            'parts' => [
              {
                'text' => call('replace_backticks_with_hash', text)
              }
            ]
          }
        ]
      }
    end,
    prep_prompt_for_text_translation: lambda do |text, from, to|
      initial_prompt = if from.present?
                         'You are an assistant helping to translate a user’s input from '\
                         "#{from} into #{to}. " \
                         "Respond only with the user’s translated text in #{
                          to} and nothing else."
                       else
                         'You are an assistant helping to translate a user’s input ' \
                         "into #{to}. Respond only with the user’s translated text " \
                         "in #{to} and nothing else. " \
                         'The user input is delimited with triple backticks.'
                       end

      {
        'contents' => [
          {
            'role' => 'user',
            'parts' => [
              {
                'text' => initial_prompt
              }
            ]
          },
          {
            'role' => 'model',
            'parts' => [
              {
                'text' => 'Thank you for your trust in me! What text do you need to translate?'
              }
            ]
          },
          {
            'role' => 'user',
            'parts' => [
              {
                'text' => "```#{call('replace_backticks_with_hash', text)}``` \nOutput this as " \
                'a JSON object with key for \'response\’'
              }
            ]
          }
        ]
      }
    end,
    prep_prompt_for_send_message: lambda do |input|
      messages = input['messages']
      if input['message_type'] == 'single_message'
        {
          'contents' => [
            {
              'role' => 'user',
              'parts' => [
                {
                  'text' => messages['message']
                }
              ]
            }
          ]
        }
      else
        {
          'contents' => messages&.[]('chat_transcript')&.map do |m|
            {
              'role' => m['role'],
              'parts' => [
                {
                  'text' => m['text']
                }
              ]
            }
          end
        }
      end
    end,
    prep_prompt_analyse_text: lambda do |question, text|
      {
        'contents' => [
          {
            'role' => 'user',
            'parts' => [
              {
                'text' => call('prompt_to_guide_ai')
              }
            ]
          },
          {
            'role' => 'model',
            'parts' => [
              {
                'text' => 'Thank you for your trust in me! What is the question?'
              }
            ]
          },
          {
            'role' => 'user',
            'parts' => [
              {
                'text' => "Information to analyse:```#{
                  call('replace_backticks_with_hash', text)}```\n" \
                "Query:```#{
                  call('replace_backticks_with_hash', question)}```\nReturn only a JSON "\
                  'object with key \"response\". '\
                'If you don’t understand the question or the answer isn’t in the information '\
                'to analyse, input the value as null for “response”. ' \
                'Only return a JSON object.'
              }
            ]
          }
        ]
      }
    end,
    prep_prompt_for_email: lambda do |text|
      inital_statement = 'You are an assistant helping to generate emails '\
      'based on the user’s input. Based on the input ensure that you generate '\
      'an appropriate subject topic and body. Ensure the body contains a '\
      'salutation and closing. The user input is delimited with triple '\
      'backticks. Use it to generate an email and perform no other actions.'
      {
        'contents' => [
          {
            'role' => 'user',
            'parts' => [
              {
                'text' => inital_statement
              }
            ]
          },
          {
            'role' => 'model',
            'parts' => [
              {
                'text' => 'Thank you for your trust in me! What is the email context?'
              }
            ]
          },
          {
            'role' => 'user',
            'parts' => [
              {
                'text' => "User description:```#{call('replace_backticks_with_hash', text)}```\n" \
                'Output the email from the user description as a JSON '\
                'object with keys for "subject" and "body". ' \
                'If an email cannot be generated, input null for the keys.'
              }
            ]
          }
        ]
      }
    end,
    prep_categories: lambda do |categories_struct, key, val|
      categories_struct&.map&.with_index do |c, _|
        if c[val].present?
          "#{c[key]} - #{c[val]}"
        else
          c[key]&.to_s
        end
      end&.join('\n')
    end,
    prep_prompt_for_parsing: lambda do |input|
      {
        'contents' => [
          {
            'role' => 'user',
            'parts' => [
              {
                'text' => 'You are an assistant helping to extract various fields ' \
                          'of information from the user\'s text. The schema ' \
                          'and text to parse are delimited by triple backticks.'
              }
            ]
          },
          {
            'role' => 'model',
            'parts' => [
              {
                'text' => 'Thank you for your trust in me! What is the schema ' \
                          'and the text to parse?'
              }
            ]
          },
          {
            'role' => 'user',
            'parts' => [
              {
                'text' => "Schema:\n```#{input['object_schema']}```\nText to parse: ```" \
                          "#{call('replace_backticks_with_hash', input['text']&.strip)}```\n" \
                          'Output the response as a JSON object with keys from the schema. ' \
                          'If no information is found for a specific key, the value should '\
                          'be null. Only respond with a JSON object and nothing else.'
              }
            ]
          }
        ]
      }
    end,
    prep_prompt_for_categorization: lambda do |text, categories_struct|
      categories = call('prep_categories', categories_struct, 'key', 'rule')

      inital_statement =
        if categories_struct.all? { |arr| arr['rule'].present? }
          'You are an assistant helping to categorise text into the various '\
          'categories mentioned. Respond with only the category name. The '\
          'categories and text to classify are delimited by triple backticks.' \
          'The category information is provided as “Category name: Rule”. Use '\
          'the rule to classify the text appropriately into one single category. '\
          'to identify the fields in the text.'
        else
          'You are an assistant helping to categorise text into the various '\
          'categories mentioned. Respond with only one category name. The '\
          'categories and text to classify are delimited by triple backticks.'
        end
      {
        'contents' => [
          {
            'role' => 'user',
            'parts' => [
              {
                'text' => inital_statement
              }
            ]
          },
          {
            'role' => 'model',
            'parts' => [
              {
                'text' => 'Thank you for your trust in me! What is the text to '\
                'parse and the categories?'
              }
            ]
          },
          {
            'role' => 'user',
            'parts' => [
              {
                'text' => "Categories:\n```#{
                  categories}```\nText to classify: ```#{
                  call('replace_backticks_with_hash',
                       text&.strip)}```\n" \
                'Output the response as a JSON object with key \"response\". '\
                'If no category is found, the \"response\" value should be null. '\
                'Only respond with a JSON object and nothing else.'\
              }
            ]
          }
        ]
      }
    end,
    prep_prompt_for_image: lambda do |question, image|
      {
        'contents' => [
          {
            'parts' => [
              {
                'text' => question
              },
              {
                'inline_data' => {
                  'mime_type' => 'image/jpeg',
                  'data' => image&.encode_base64
                }
              }
            ]
          }
        ]
      }
    end,
    prep_prompt_for_embedding: lambda do |model, text|
      {
        'model' => model,
        'content' => {
          'parts' => [
            {
              'text' => text
            }
          ]
        }
      }
    end,
    apply_config_settings: lambda do |input, req|
      safety_settings = []
      safety_settings_gen = input['safetySettings']&.map do |s|
        next if s['category'].blank? || s['threshold'].blank?

        safety_settings << {
          'category' => s['category'],
          'threshold' => s['threshold']
        }
      end&.compact
      req['safetySettings'] = safety_settings_gen unless safety_settings_gen.blank?

      gen_config = {
        'stopSequences' => input.dig('generationConfig', 'stopSequences'),
        'temperature' => input.dig('generationConfig', 'temperature') || 0,
        'maxOutputTokens' => input.dig('generationConfig', 'maxOutputTokens'),
        'topP' => input.dig('generationConfig', 'topP'),
        'topK' => input.dig('generationConfig', 'topK')
      }&.compact
      req['generationConfig'] = gen_config unless gen_config.blank?
      req
    end,
    replace_backticks_with_hash: lambda do |text|
      text&.gsub('```', '####')
    end,
    extract_json: lambda do |resp|
      json_txt = resp&.dig('candidates', 0, 'content', 'parts', 0, 'text')
      json = json_txt.gsub(/```json|```JSON|`+$/, '')&.strip
      parse_json(json) || {}
    end,
    extract_generic_respononse: lambda do |resp, is_json_response|
      call('check_finish_reason', resp.dig('candidates', 0, 'finishReason'))
      ratings = call('get_safety_ratings', resp.dig('candidates', 0, 'safetyRatings'))
      next { 'answer' => 'N/A', 'safety_ratings' => {} } if ratings.blank?

      answer = if is_json_response
                 call('extract_json', resp)&.[]('response')
               else
                 resp&.dig('candidates', 0, 'content', 'parts', 0, 'text')
               end
      {
        'answer' => answer,
        'safety_ratings' => ratings
      }
    end,
    extract_generated_email_response: lambda do |resp|
      call('check_finish_reason', resp.dig('candidates', 0, 'finishReason'))
      ratings = call('get_safety_ratings', resp.dig('candidates', 0, 'safetyRatings'))
      json = call('extract_json', resp)
      {
        'subject' => json&.[]('subject'),
        'body' => json&.[]('body'),
        'safety_ratings' => ratings
      }
    end,
    extract_parsed_response: lambda do |resp|
      call('check_finish_reason', resp.dig('candidates', 0, 'finishReason'))
      ratings = call('get_safety_ratings', resp.dig('candidates', 0, 'safetyRatings'))
      json = call('extract_json', resp)
      found_categories = {}
      json&.each do |k, v|
        found_categories[k] = v
      end
      found_categories =
        found_categories.merge(
          {
            'safety_ratings' => ratings
          }
        )
    end,
    get_models: lambda do |is_for_picklist|
      get('models')&.[]('models')&.select { |model| model['name'].include?('.') }&.
        map do |m|
          name = m['name']
          label = m['displayName']
          if is_for_picklist
            [label, name]
          else
            {
              label: label,
              name: name
            }
          end
        end
    end,
    check_finish_reason: lambda do |reason|
      case reason&.downcase
      when 'agent_disconnect'
        error 'SYSTEM ERROR - Agent suddently disconnected, please try later'
      when 'error'
        error 'ERROR - An error occurred, try again later'
      when 'invalid_argument'
        error 'BAD INOUT - The agent recieved an invalid argument '\
        'it could be because it is busy or the input was invalid'
      when 'safety'
        error 'SAFETY - The agent was not able to answer because of the saftey reason'
      when 'other'
        error 'OTHER- The agent was not able to answer because of the unknown reason'
      when 'no_answer'
        error 'ERROR - The agent was not able to answer the requested query'
      when 'no_agent'
        error 'ERROR - The call was not answered because there were no available agents'
      when 'queue_timeout'
        error 'ERROR - The call was not answered because it timed out in the queue'
      when 'transfer'
        error 'ERROR - The call was transferred to another agent or queue'
      when 'unknown'
        error 'ERROR - The reason for the call ending is unknown'
      end
    end,
    test_models: lambda do
      call('get_models', true)
    end,
    get_safety_ratings: lambda do |ratings|
      {
        'sexually_explicit' =>
          ratings&.find do |r|
            r['category'] == 'HARM_CATEGORY_SEXUALLY_EXPLICIT'
          end&.[]('probability'),
        'hate_speech' =>
          ratings&.find { |r| r['category'] == 'HARM_CATEGORY_HATE_SPEECH' }&.[]('probability'),
        'harassment' =>
          ratings&.find { |r| r['category'] == 'HARM_CATEGORY_HARASSMENT' }&.[]('probability'),
        'dangerous_content' =>
          ratings&.find do |r|
            r['category'] == 'HARM_CATEGORY_DANGEROUS_CONTENT'
          end&.[]('probability')
      }
    end,
    get_analyse_text_input_schema: lambda do |_model|
      [
        {
          name: 'text',
          label: 'Source text',
          type: 'string',
          hint: 'Provide the text to be analysed.',
          optional: false
        },
        {
          name: 'question',
          label: 'Instruction',
          type: 'string',
          hint: 'Enter analysis instructions, such as an analysis '\
          'technique or question to be answered.',
          optional: false
        }
      ]
    end,
    get_analyze_image_input_schema: lambda do |_model|
      [
        {
          name: 'question',
          label: 'Your question about the image',
          type: 'string',
          hint: 'Plesae specify a clear question for image analysis.',
          optional: false
        },
        {
          name: 'image',
          label: 'Image data',
          type: 'string',
          hint: 'Provide the image to be analysed - image should be in base64 encoding.',
          optional: false
        }
      ]
    end,
    get_safety_ratings_schema: lambda do
      {
        name: 'safety_ratings',
        label: 'Safety ratings',
        type: 'object',
        properties: [
          {
            name: 'sexually_explicit',
            label: 'Sexually explicit',
            type: 'string'
          },
          {
            name: 'hate_speech',
            label: 'Hate speech',
            type: 'string'
          },
          {
            name: 'harassment',
            label: 'Harassment',
            type: 'string'
          },
          {
            name: 'dangerous_content',
            label: 'Dangerous content',
            type: 'string'
          }
        ]
      }
    end,
    get_analysis_output_schema: lambda do |_config_fields|
      [
        {
          name: 'answer',
          label: 'Gemini reply',
          type: 'string'
        }
      ] << call('get_safety_ratings_schema')
    end,
    get_embeding_input_schema: lambda do |_config_fields|
      [
        {
          name: 'text',
          label: 'Text for embeding generation',
          type: 'string',
          control_type: 'text-area',
          hint: 'Input text must not exceed 8192 tokens (approximately 6000 words).',
          optional: false
        }
      ]
    end,
    get_embeding_output_schema: lambda do |_config_fields|
      [
        {
          name: 'embedding',
          label: 'Embedding',
          type: 'array',
          of: 'object',
          properties: [
            {
              name: 'value',
              label: 'Value',
              type: 'number',
              parse_output: 'float_conversion'
            }
          ]
        }
      ]
    end,
    get_draft_email_input_schema: lambda do |_config_fields|
      [
        {
          name: 'email_description',
          label: 'Email description',
          type: 'string',
          control_type: 'text-area',
          optional: false,
          hint: 'Enter a description for the email'
        }
      ]
    end,
    get_draft_email_output_schema: lambda do |_config_fields|
      [
        {
          name: 'subject',
          label: 'Email subject',
          type: 'string'
        },
        {
          name: 'body',
          label: 'Email body',
          type: 'string'
        }
      ] << call('get_safety_ratings_schema')
    end,
    get_categorise_text_input_schema: lambda do |_config_fields|
      [
        {
          name: 'text',
          label: 'Source text',
          type: 'string',
          control_type: 'text-area',
          optional: false,
          hint: 'Provide the text to be categorised'
        },
        {
          name: 'categories',
          control_type: 'key_value',
          label: 'List of categories',
          empty_list_title: 'List is empty',
          empty_list_text: 'Please add relevant categories',
          item_label: 'Category',
          extends_schema: true,
          type: 'array',
          of: 'object',
          optional: false,
          hint: 'Create a list of categories to sort the text into. Rules are '\
          'used to provide additional details to help classify what each category represents',
          properties: [
            {
              name: 'key',
              label: 'Category',
              type: 'string',
              hint: 'Enter category name'
            },
            {
              name: 'rule',
              label: 'Rule',
              type: 'string',
              hint: 'Enter rule'
            }
          ]
        }
      ]
    end,
    get_categorise_text_output_schema: lambda do |_config_fields|
      [
        {
          name: 'answer',
          label: 'Best matching category',
          type: 'string'
        }
      ] << call('get_safety_ratings_schema')
    end,
    get_parse_text_input_schema: lambda do |_config_fields|
      [
        {
          name: 'text',
          label: 'Source text',
          type: 'string',
          control_type: 'text-area',
          optional: false,
          hint: 'Provide the text to be parsed'
        },
        {
          name: 'object_schema',
          optional: false,
          control_type: 'schema-designer',
          extends_schema: true,
          sample_data_type: 'json_http',
          empty_schema_title: 'Provide output fields for your job output.',
          label: 'Fields to identify',
          hint: 'Enter the fields that you want to identify from the text. Add descriptions for ' \
                'extracting the fields. Required fields take effect only on top level. ' \
                'Nested fields are always optional.',
          exclude_fields: %w[hint label],
          exclude_fields_types: %w[integer date date_time],
          custom_properties: [
            {
              name: 'description',
              type: 'string',
              optional: true,
              label: 'Description'
            }
          ]
        }
      ]
    end,
    get_parse_text_output_schema: lambda do |config_fields|
      schema = parse_json(config_fields['object_schema'] || '[]')
      schema << call('get_safety_ratings_schema')
    end,
    get_summarize_text_input_schema: lambda do |_config_fields|
      [
        {
          name: 'text',
          label: 'Source text',
          type: 'string',
          control_type: 'text-area',
          optional: false,
          hint: 'Provide the text to be summarized'
        },
        {
          name: 'max_words',
          label: 'Maximum words',
          type: 'integer',
          control_type: 'integer',
          optional: true,
          sticky: true,
          hint: 'Enter the maximum number of words for the summary. '\
          "If left blank, defaults to #{call('summirize_max_words')}"
        }
      ]
    end,
    get_translate_text_input_schema: lambda do |_config_fields|
      [
        {
          name: 'to',
          label: 'Output language',
          optional: false,
          control_type: 'select',
          pick_list: :languages_picklist,
          toggle_field: {
            name: 'to',
            control_type: 'text',
            type: 'string',
            optional: false,
            label: 'Output language',
            toggle_hint: 'Provide custom value',
            hint: 'Enter the output language. Eg. English'
          },
          toggle_hint: 'Select from list',
          hint: 'Select the desired output language'
        },
        {
          name: 'from',
          label: 'Source language',
          optional: true,
          sticky: true,
          control_type: 'select',
          pick_list: :languages_picklist,
          toggle_field: {
            name: 'from',
            control_type: 'text',
            type: 'string',
            optional: true,
            label: 'Source language',
            toggle_hint: 'Provide custom value',
            hint: 'Enter the source language. Eg. English'
          },
          toggle_hint: 'Select from list',
          hint: 'Select the source language. If this value is left blank, we will '\
          'automatically attempt to identify it.'
        },
        {
          name: 'text',
          label: 'Source text',
          type: 'string',
          control_type: 'text-area',
          optional: false,
          hint: 'Enter the text to be translated. Please limit to 2000 tokens'
        }
      ]
    end,
    get_send_messages_input_schema: lambda do |config_fields|
      is_single_message = config_fields['message_type'] == 'single_message'
      message_schema = if is_single_message
                         [{
                           name: 'message',
                           label: 'Text to send',
                           type: 'string',
                           control_type: 'text-area',
                           optional: false,
                           hint: 'Enter a message to start a conversation with Gemini.'
                         }]
                       else
                         [
                           {
                             name: 'system_role_message',
                             label: 'System role message',
                             type: 'string',
                             control_type: 'text-area',
                             optional: true,
                             hint: 'The contents of the system role message.'
                           },
                           {
                             name: 'chat_transcript',
                             label: 'Chat transcript',
                             type: 'array',
                             of: 'object',
                             optional: false,
                             properties: [
                               {
                                 name: 'role',
                                 type: 'string',
                                 control_type: 'select',
                                 pick_list: :chat_role,
                                 optional: false,
                                 extends_schema: true,
                                 hint: 'Select the role of the author of this message.',
                                 toggle_field: {
                                   name: 'role',
                                   label: 'Role',
                                   control_type: 'text',
                                   type: 'string',
                                   optional: false,
                                   extends_schema: true,
                                   toggle_hint: 'Use custom value',
                                   hint: 'Provide the role of the author of this message. Allowed '\
                                   'values: <b>user</b> or <b>model</b>.'
                                 },
                                 toggle_hint: 'Select from list'
                               },
                               {
                                 name: 'text',
                                 type: 'string',
                                 control_type: 'text-area',
                                 optional: false,
                                 hint: 'The contents of the selected role message.'
                               }
                             ],
                             hint: 'A list of messages describing the conversation so far.'
                           }
                         ]
                       end
      [
        {
          name: 'messages',
          label: is_single_message ? 'Message' : 'Messages',
          type: 'object',
          optional: false,
          properties: message_schema
        }
      ] + call('get_config_schema')
    end,
    get_config_schema: lambda do
      [
        {
          name: 'safetySettings',
          label: 'Safety settings',
          type: 'array',
          of: 'object',
          optional: true,
          hint: 'Specify safety settings when relevant',
          properties: [
            {
              name: 'category',
              label: 'Category',
              control_type: 'select',
              pick_list: :get_config_categories,
              hint: 'Select appropriate safety category',
              optional: true,
              toggle_hint: 'Select from list',
              toggle_field: {
                name: 'category',
                label: 'Category',
                hint: 'Acceptable values are: HARM_CATEGORY_DANGEROUS_CONTENT, '\
                'HARM_CATEGORY_HATE_SPEECH, HARM_CATEGORY_HARASSMENT, '\
                'HARM_CATEGORY_SEXUALLY_EXPLICIT',
                type: 'string',
                control_type: 'text',
                optional: true,
                toggle_hint: 'Provide a safety category'
              }
            },
            {
              name: 'threshold',
              label: 'Threshold',
              control_type: 'select',
              pick_list: :get_config_threshold,
              hint: 'Select appropriate safety threshold',
              optional: true,
              toggle_hint: 'Select from list',
              toggle_field: {
                name: 'threshold',
                label: 'Threshold',
                hint: 'Acceptable values are: BLOCK_ONLY_HIGH, BLOCK_NONE BLOCK_NONE, '\
                'BLOCK_MEDIUM_AND_ABOVE, BLOCK_LOW_AND_ABOVE, HARM_BLOCK_THRESHOLD_UNSPECIFIED',
                type: 'string',
                control_type: 'text',
                optional: true,
                toggle_hint: 'Provide a safety threshold'
              }
            }
          ]
        },
        {
          name: 'generationConfig',
          label: 'Generation config',
          type: 'object',
          optional: true,
          hint: 'Specify parameter that suitable for your use case',
          properties: [
            {
              name: 'stopSequences',
              label: 'Stop sequences',
              type: 'array',
              of: 'string',
              optional: true,
              hint: 'A list of strings that the model will stop generating text at.'
            },
            {
              name: 'temperature',
              label: 'Temperature',
              type: 'number',
              convert_input: 'float_conversion',
              optional: true,
              hint: 'A number that controls the randomness of the model\'s output. '\
              'A higher temperature will result in more random output, while a '\
              'lower temperature will result in more predictable output'
            },
            {
              name: 'maxOutputTokens',
              label: 'Max output tokens',
              type: 'number',
              convert_input: 'integer_conversion',
              optional: true,
              hint: 'The maximum number of tokens that the model will generate.'
            },
            {
              name: 'topP',
              label: 'TopP',
              type: 'number',
              convert_input: 'float_conversion',
              optional: true,
              hint: 'A number that controls the probability of the model generating each token. '\
              'A higher topP will result in the model generating more likely tokens, while a '\
              'lower topP will result in the model generating more unlikely tokens. '\
              'Allowed Values: Any decimal value between 0 and 1.'
            },
            {
              name: 'topK',
              label: 'TopK',
              type: 'number',
              convert_input: 'float_conversion',
              optional: true,
              hint: 'A number that controls the number of tokens that the model considers when '\
              'generating each token. A higher topK will result in the model considering more '\
              'tokens, while a lower topK will result in the model considering fewer tokens. '\
              'Allowed Values: Any positive integer.'
            }
          ]
        }
      ]
    end,
    safety_ratings_output_sample: lambda do
      {
        'safety_ratings' => {
          'sexually_explicit' => 'NEGLIGIBLE',
          'hate_speech' => 'NEGLIGIBLE',
          'harassment' => 'NEGLIGIBLE',
          'dangerous_content' => 'NEGLIGIBLE'
        }
      }
    end
  },

  object_definitions: {
    analyse_text_input: {
      fields: lambda do |_connection, config_fields, _object_definitions|
        call('get_analyse_text_input_schema', config_fields['model'])
      end
    },
    analyse_text_output: {
      fields: lambda do |_connection, config_fields, _object_definitions|
        call('get_analysis_output_schema', config_fields)
      end
    },
    analyze_image_input: {
      fields: lambda do |_connection, config_fields, _object_definitions|
        call('get_analyze_image_input_schema', config_fields['model'])
      end
    },
    analyze_image_output: {
      fields: lambda do |_connection, config_fields, _object_definitions|
        call('get_analysis_output_schema', config_fields)
      end
    },
    embedding_input: {
      fields: lambda do |_connection, config_fields, _object_definitions|
        call('get_embeding_input_schema', config_fields['model'])
      end
    },
    embedding_output: {
      fields: lambda do |_connection, config_fields, _object_definitions|
        call('get_embeding_output_schema', config_fields)
      end
    },
    draft_email_input: {
      fields: lambda do |_connection, config_fields, _object_definitions|
        call('get_draft_email_input_schema', config_fields['model'])
      end
    },
    draft_email_output: {
      fields: lambda do |_connection, config_fields, _object_definitions|
        call('get_draft_email_output_schema', config_fields)
      end
    },
    categorise_text_input: {
      fields: lambda do |_connection, config_fields, _object_definitions|
        call('get_categorise_text_input_schema', config_fields['model'])
      end
    },
    categorise_text_output: {
      fields: lambda do |_connection, config_fields, _object_definitions|
        call('get_categorise_text_output_schema', config_fields)
      end
    },
    parse_text_input: {
      fields: lambda do |_connection, config_fields, _object_definitions|
        call('get_parse_text_input_schema', config_fields['model'])
      end
    },
    parse_text_output: {
      fields: lambda do |_connection, config_fields, _object_definitions|
        call('get_parse_text_output_schema', config_fields)
      end
    },
    summarize_text_input: {
      fields: lambda do |_connection, config_fields, _object_definitions|
        call('get_summarize_text_input_schema', config_fields['model'])
      end
    },
    summarize_text_output: {
      fields: lambda do |_connection, config_fields, _object_definitions|
        call('get_analysis_output_schema', config_fields)
      end
    },
    translate_text_input: {
      fields: lambda do |_connection, config_fields, _object_definitions|
        call('get_translate_text_input_schema', config_fields)
      end
    },
    translate_text_output: {
      fields: lambda do |_connection, config_fields, _object_definitions|
        call('get_analysis_output_schema', config_fields)
      end
    },
    send_messages_input: {
      fields: lambda do |_connection, config_fields, _object_definitions|
        call('get_send_messages_input_schema', config_fields)
      end
    },
    send_messages_output: {
      fields: lambda do |_connection, config_fields, _object_definitions|
        call('get_analysis_output_schema', config_fields)
      end
    }
  },

  pick_lists: {
    available_text_models: lambda do
      call('get_models', true)&.map do |m|
        model = m.join
        m unless model.include?('latest') ||
                 model.include?('vision') ||
                 model.include?('embed')
      end&.compact&.uniq
    end,
    available_vision_models: lambda do
      call('get_models', true)&.map do |m|
        model = m.join
        m unless model.include?('1.0') ||
                 model.include?('vision') ||
                 model.include?('embed')
      end&.compact
    end,
    available_embedding_models: lambda do
      call('get_models', true)&.map { |m| m if m.join.include?('embed') }&.compact
    end,
    get_config_categories: lambda do
      [
        %w[HARM_CATEGORY_DANGEROUS_CONTENT HARM_CATEGORY_DANGEROUS_CONTENT],
        %w[HARM_CATEGORY_HATE_SPEECH HARM_CATEGORY_HATE_SPEECH],
        %w[HARM_CATEGORY_HARASSMENT HARM_CATEGORY_HARASSMENT],
        %w[HARM_CATEGORY_SEXUALLY_EXPLICIT HARM_CATEGORY_SEXUALLY_EXPLICIT]
      ]
    end,
    get_config_threshold: lambda do
      [
        %w[BLOCK_ONLY_HIGH BLOCK_ONLY_HIGH],
        %w[BLOCK_NONE BLOCK_NONE],
        %w[BLOCK_MEDIUM_AND_ABOVE BLOCK_MEDIUM_AND_ABOVE],
        %w[BLOCK_LOW_AND_ABOVE BLOCK_LOW_AND_ABOVE],
        %w[HARM_BLOCK_THRESHOLD_UNSPECIFIED HARM_BLOCK_THRESHOLD_UNSPECIFIED]
      ]
    end,
    languages_picklist: lambda do
      [
        'Albanian', 'Arabic', 'Armenian', 'Awadhi', 'Azerbaijani', 'Bashkir', 'Basque',
        'Belarusian', 'Bengali', 'Bhojpuri', 'Bosnian', 'Brazilian Portuguese', 'Bulgarian',
        'Cantonese (Yue)', 'Catalan', 'Chhattisgarhi', 'Chinese', 'Croatian', 'Czech', 'Danish',
        'Dogri', 'Dutch', 'English', 'Estonian', 'Faroese', 'Finnish', 'French', 'Galician',
        'Georgian', 'German', 'Greek', 'Gujarati', 'Haryanvi', 'Hindi',
        'Hungarian', 'Indonesian', 'Irish', 'Italian', 'Japanese', 'Javanese', 'Kannada',
        'Kashmiri', 'Kazakh', 'Konkani', 'Korean', 'Kyrgyz', 'Latvian', 'Lithuanian',
        'Macedonian', 'Maithili', 'Malay', 'Maltese', 'Mandarin', 'Mandarin Chinese', 'Marathi',
        'Marwari', 'Min Nan', 'Moldovan', 'Mongolian', 'Montenegrin', 'Nepali', 'Norwegian',
        'Oriya', 'Pashto', 'Persian (Farsi)', 'Polish', 'Portuguese', 'Punjabi', 'Rajasthani',
        'Romanian', 'Russian', 'Sanskrit', 'Santali', 'Serbian', 'Sindhi', 'Sinhala', 'Slovak',
        'Slovene', 'Slovenian', 'Swedish', 'Ukrainian', 'Urdu', 'Uzbek', 'Vietnamese',
        'Welsh', 'Wu'
      ]
    end,
    message_types: lambda do
      %w[single_message chat_transcript].map { |m| [m.humanize, m] }
    end,
    chat_role: lambda do
      %w[model user].map { |o| [o.humanize, o] }
    end
  }
}