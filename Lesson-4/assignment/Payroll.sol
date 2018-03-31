pragma solidity ^0.4.14;

import './SafeMath.sol';
import './Ownable.sol';

contract Payroll is Ownable {

	using SafeMath for uint;

    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }
    
    uint totalSalary = 0;
    
    uint constant payDuration = 10 seconds;

    address owner;
    mapping(address => Employee) public employees;

    modifier employeeExist(address employeeId) {
    	var employee = employees[employeeId];
    	assert(employee.id != 0x0);
    	_;
    }

    function changePaymentAddress(address previousId, address currentId) onlyOwner employeeExist(previousId) {
        var employee = employees[previousId];
        addEmployee(currentId, employee.salary.div(1 ether));
        removeEmployee(previousId);
 	}

    function _partialPaid(Employee employee) private {
        uint payment = employee.salary
        	 .mul(now.sub(employee.lastPayday))
        	 .div(payDuration);
        employee.id.transfer(payment);
    }

    function addEmployee(address employeeId, uint salary) onlyOwner {
        var employee = employees[employeeId];
        assert(employee.id == 0x0);
        
        employees[employeeId] = Employee(employeeId, salary.mul(1 ether), now);
        totalSalary = totalSalary.add(salary.mul(1 ether));
    }
    
    function removeEmployee(address employeeId) onlyOwner employeeExist(employeeId) {
        var employee = employees[employeeId];
        
        _partialPaid(employee);
        totalSalary = totalSalary.sub(employee.salary);
        delete employees[employeeId];
    }
    
    function updateEmployee(address employeeId, uint salary) onlyOwner employeeExist(employeeId) {
        var employee = employees[employeeId];
        
        uint newSalary = salary.mul(1 ether);

        totalSalary = totalSalary.add(newSalary).sub(employees[employeeId].salary.mul(1 ether));
        _partialPaid(employee);
        employees[employeeId].salary = newSalary;
        employees[employeeId].lastPayday = now;
    }
    function getTotalSalary() returns (uint) {
	return totalSalary;
    }
   
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        return this.balance.div(totalSalary);
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() employeeExist(msg.sender){
        var employee= employees[msg.sender];
        
        uint nextPayDay = employee.lastPayday.add(payDuration);
        assert(nextPayDay < now);
        
        employee.lastPayday = nextPayDay;
        employee.id.transfer(employee.salary);
    }
}
