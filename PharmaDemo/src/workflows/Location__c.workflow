<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Name_on_Location</fullName>
        <field>Name</field>
        <formula>Account__r.Name &amp; &apos; - &apos; &amp; Contact__r.Full_Name__c</formula>
        <name>Update Name on Location</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Unique_Id_on_Location</fullName>
        <field>Unique_Id__c</field>
        <formula>Contact__c &amp; &quot;|&quot; &amp; Account__c</formula>
        <name>Update Unique Id on Location</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Name on Location</fullName>
        <actions>
            <name>Update_Name_on_Location</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Unique Id on Location</fullName>
        <actions>
            <name>Update_Unique_Id_on_Location</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the unique id field on Location object</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
