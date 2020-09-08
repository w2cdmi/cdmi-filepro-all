package pw.cdmi.box.disk.declare.service;

import pw.cdmi.common.domain.ConcealDeclare;

public interface ConcealDeclareService
{
    ConcealDeclare getDeclaration(ConcealDeclare declare);
    
    ConcealDeclare getDeclarationById(String declarationId);
    
    void create(ConcealDeclare declare);
    
    void delete(ConcealDeclare declare);
}
