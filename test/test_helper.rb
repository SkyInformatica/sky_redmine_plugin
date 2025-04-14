# Load the Redmine helper
require_relative '../../../test/test_helper'

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

# Configuração para usar o banco de dados de produção nos testes
ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS=0")
ActiveRecord::Base.connection.execute("SET SQL_MODE='NO_AUTO_VALUE_ON_ZERO'")

# Desabilitar transações para evitar problemas com o banco de produção
class ActiveSupport::TestCase
  self.use_transactional_tests = false
end

# Configurar o ambiente de teste para usar o banco de produção
ENV['RAILS_ENV'] = 'production'
ENV['RAILS_TEST_DB'] = 'redmine'
