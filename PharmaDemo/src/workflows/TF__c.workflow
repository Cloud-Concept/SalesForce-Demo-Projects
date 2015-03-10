<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Active_TF</fullName>
        <field>Active__c</field>
        <literalValue>1</literalValue>
        <name>Active TF</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approved_record</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ApprovedTargetFrequency</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Approved Record</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Inactive_TF</fullName>
        <field>Active__c</field>
        <literalValue>0</literalValue>
        <name>Inactive TF</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Pending_Record</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Pending_Target_Frequency</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Pending Record</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Recalled</fullName>
        <field>Status__c</field>
        <literalValue>Recalled</literalValue>
        <name>Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reject_Record</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Rejected_Target_Frequency</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Reject Record</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Submitted_Record</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Submitted_Target_Frequency</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Submitted Record</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Unique_Id_on_TF</fullName>
        <field>Unique_Id__c</field>
        <formula>Target__r.MedRep__r.Id  &amp; &quot;|&quot; &amp; Customer__c</formula>
        <name>Update Unique Id on TF</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Unique Id on TF</fullName>
        <actions>
            <name>Update_Unique_Id_on_TF</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
