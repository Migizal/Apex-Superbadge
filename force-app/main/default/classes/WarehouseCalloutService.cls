public with sharing class WarehouseCalloutService{

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';

    //@future(callout=true)
    public static void exeWarehouseEquipmentSync(){

        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        List<Product2> warehouseEquip = new List<Product2>();

        if(response.getStatusCode() == 200){
            List<Object> jsonResponse = (List<Object>)JSON.deserializeUntyped(response.getBody());
            System.debug(response.getBody());

            for(Object eq :jsonResponse){
                Map<String, Object> mapJson = (Map<String, Object>)eq;
                Product2 myEquip = new Product2();
                myEquip.Replacement_Part__c = (Boolean)mapJson.get('replacement');
                myEquip.Name = (String)mapJson.get('name');
                myEquip.Maintenance_Cycle__c = (Integer)mapJson.get('maintenanceperiod');
                myEquip.Lifespan_Months__c = (Integer)mapJson.get('lifespan');
                myEquip.Cost__c = (Integer)mapJson.get('cost');
                MyEquip.Current_Inventory__c = (Double)mapJson.get('quantity');
                myEquip.Warehouse_SKU__c = (String)mapJson.get('sku');
                WarehouseEquip.add(myEquip);
            }
            if(warehouseEquip.size()>0){
                upsert warehouseEquip;
                System.debug('Your equipment was synced with the warehouse equipment');
                System.debug(warehouseEquip);
            }
        }
    }  
}