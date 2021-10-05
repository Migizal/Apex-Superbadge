@isTest
global class WarehouseCalloutServiceMock implements HttpCalloutMock {
    // implement http mock callout
    global static HttpResponse respond(HttpRequest request){
        System.assertEquals('GET', request.getMethod());

        //fake response
        HttpResponse response = new Httpresponse();
        response.setHeader('Content-Type', 'application/json');

        response.setBody('[{"_id":"55d66226726b611100aaf741","replacement":false,"quantity":4,"name":"Generator 1000 kW","maintenanceperiod":365,"lifespan":120,"cost":6000,"sku":"163783"}]');
        response.setStatusCode(200);
        return response;
    }

}