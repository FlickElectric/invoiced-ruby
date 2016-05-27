require File.expand_path('../../test_helper', __FILE__)

module Invoiced
  class CustomerTest < Test::Unit::TestCase
    should "return the api endpoint" do
      customer = Customer.new(@client, 123)
      assert_equal('/customers/123', customer.endpoint())
    end

    should "create a customer" do
      mockResponse = mock('RestClient::Response')
      mockResponse.stubs(:code).returns(201)
      mockResponse.stubs(:body).returns('{"id":123,"name":"Pied Piper"}')
      mockResponse.stubs(:headers).returns({})

      RestClient::Request.any_instance.expects(:execute).returns(mockResponse)

      customer = @client.Customer.create({:name => "Pied Piper"})

      assert_instance_of(Invoiced::Customer, customer)
      assert_equal(123, customer.id)
      assert_equal('Pied Piper', customer.name)
    end

    should "retrieve a customer" do
      mockResponse = mock('RestClient::Response')
      mockResponse.stubs(:code).returns(200)
      mockResponse.stubs(:body).returns('{"id":123,"name":"Pied Piper"}')
      mockResponse.stubs(:headers).returns({})

      RestClient::Request.any_instance.expects(:execute).returns(mockResponse)

      customer = @client.Customer.retrieve(123)

      assert_instance_of(Invoiced::Customer, customer)
      assert_equal(123, customer.id)
      assert_equal('Pied Piper', customer.name)
    end

    should "not update a customer when no params" do
      customer = Customer.new(@client, 123)
      assert_false(customer.save)
    end

    should "update a customer" do
      mockResponse = mock('RestClient::Response')
      mockResponse.stubs(:code).returns(200)
      mockResponse.stubs(:body).returns('{"id":123,"name":"Pied Piper","notes":"Terrible customer"}')
      mockResponse.stubs(:headers).returns({})

      RestClient::Request.any_instance.expects(:execute).returns(mockResponse)

      customer = Customer.new(@client, 123)
      customer.notes = 'Terrible customer'
      assert_true(customer.save)

      assert_equal("Terrible customer", customer.notes)
    end

    should "list all customers" do
      mockResponse = mock('RestClient::Response')
      mockResponse.stubs(:code).returns(200)
      mockResponse.stubs(:body).returns('[{"id":123,"name":"Pied Piper"}]')
      mockResponse.stubs(:headers).returns(:x_total_count => 15, :link => '<https://api.invoiced.com/customers?per_page=25&page=1>; rel="self", <https://api.invoiced.com/customers?per_page=25&page=1>; rel="first", <https://api.invoiced.com/customers?per_page=25&page=1>; rel="last"')

      RestClient::Request.any_instance.expects(:execute).returns(mockResponse)

      customers, metadata = @client.Customer.list

      assert_instance_of(Array, customers)
      assert_equal(1, customers.length)
      assert_equal(123, customers[0].id)

      assert_instance_of(Invoiced::List, metadata)
      assert_equal(15, metadata.total_count)
    end

    should "delete a customer" do
      mockResponse = mock('RestClient::Response')
      mockResponse.stubs(:code).returns(204)
      mockResponse.stubs(:body).returns('')
      mockResponse.stubs(:headers).returns({})

      RestClient::Request.any_instance.expects(:execute).returns(mockResponse)

      customer = Customer.new(@client, 123)
      assert_true(customer.delete)
    end

    should "send an account statement" do
      mockResponse = mock('RestClient::Response')
      mockResponse.stubs(:code).returns(201)
      mockResponse.stubs(:body).returns('[{"id":4567,"email":"test@example.com"}]')
      mockResponse.stubs(:headers).returns({})

      RestClient::Request.any_instance.expects(:execute).returns(mockResponse)

      customer = Customer.new(@client, 123)
      emails = customer.send_statement

      assert_instance_of(Array, emails)
      assert_equal(1, emails.length)
      assert_instance_of(Invoiced::Email, emails[0])
      assert_equal(4567, emails[0].id)
    end

    should "retrieve a customer's balance" do
      mockResponse = mock('RestClient::Response')
      mockResponse.stubs(:code).returns(200)
      mockResponse.stubs(:body).returns('{"total_outstanding":1000,"available_credits":0,"past_due":true}')
      mockResponse.stubs(:headers).returns({})

      RestClient::Request.any_instance.expects(:execute).returns(mockResponse)

      customer = Customer.new(@client, 123)
      balance = customer.balance

      expected = {
        :past_due => true,
        :available_credits => 0,
        :total_outstanding => 1000
      }

      assert_equal(expected, balance)
    end

    should "create a pending line item" do
      mockResponse = mock('RestClient::Response')
      mockResponse.stubs(:code).returns(201)
      mockResponse.stubs(:body).returns('{"id":123,"unit_cost":500}')
      mockResponse.stubs(:headers).returns({})

      RestClient::Request.any_instance.expects(:execute).returns(mockResponse)

      customer = Customer.new(@client, 456)
      line_item = customer.line_items.create({:unit_cost => 500})

      assert_instance_of(Invoiced::LineItem, line_item)
      assert_equal(123, line_item.id)
      assert_equal(500, line_item.unit_cost)
      assert_equal('/customers/456/line_items/123', line_item.endpoint())
    end

    should "list all of the customer's pending line item" do
      mockResponse = mock('RestClient::Response')
      mockResponse.stubs(:code).returns(200)
      mockResponse.stubs(:body).returns('[{"id":123,"unit_cost":500}]')
      mockResponse.stubs(:headers).returns(:x_total_count => 10, :link => '<https://api.invoiced.com/customers/123/line_items?per_page=25&page=1>; rel="self", <https://api.invoiced.com/customers/123/line_items?per_page=25&page=1>; rel="first", <https://api.invoiced.com/customers/123/line_items?per_page=25&page=1>; rel="last"')

      RestClient::Request.any_instance.expects(:execute).returns(mockResponse)

      customer = Customer.new(@client, 456)
      line_items, metadata = customer.line_items.list

      assert_instance_of(Array, line_items)
      assert_equal(1, line_items.length)
      assert_equal(123, line_items[0].id)
      assert_equal('/customers/456/line_items/123', line_items[0].endpoint())

      assert_instance_of(Invoiced::List, metadata)
      assert_equal(10, metadata.total_count)
    end

    should "retrieve a pending line item" do
      mockResponse = mock('RestClient::Response')
      mockResponse.stubs(:code).returns(200)
      mockResponse.stubs(:body).returns('{"id":123,"unit_cost":500}')
      mockResponse.stubs(:headers).returns({})

      RestClient::Request.any_instance.expects(:execute).returns(mockResponse)

      customer = Customer.new(@client, 456)
      line_item = customer.line_items.retrieve(123)

      assert_instance_of(Invoiced::LineItem, line_item)
      assert_equal(123, line_item.id)
      assert_equal(500, line_item.unit_cost)
      assert_equal('/customers/456/line_items/123', line_item.endpoint())
    end

    should "create an invoice" do
      mockResponse = mock('RestClient::Response')
      mockResponse.stubs(:code).returns(201)
      mockResponse.stubs(:body).returns('{"id":4567,"total":100}')
      mockResponse.stubs(:headers).returns({})

      RestClient::Request.any_instance.expects(:execute).returns(mockResponse)

      customer = Customer.new(@client, 123)
      invoice = customer.invoice

      assert_instance_of(Invoiced::Invoice, invoice)
      assert_equal(4567, invoice.id)
    end
  end
end