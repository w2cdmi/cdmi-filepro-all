package pw.cdmi.box.disk.declare.service.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import pw.cdmi.box.disk.declare.dao.ConcealDeclareDao;
import pw.cdmi.box.disk.declare.service.ConcealDeclareService;
import pw.cdmi.common.domain.ConcealDeclare;

@Service
public class ConcealDeclareServiceImpl implements ConcealDeclareService
{
    
    @Autowired
    private ConcealDeclareDao concealDeclareDao;
    
    @Override
    public ConcealDeclare getDeclaration(ConcealDeclare declare)
    {
        return concealDeclareDao.getDeclaration(declare);
    }
    
    @Override
    public void create(ConcealDeclare declare)
    {
        concealDeclareDao.create(declare);
    }
    
    @Override
    public void delete(ConcealDeclare declare)
    {
        if (null != declare.getAppId() && null != declare.getClientType())
        {
            concealDeclareDao.delete(declare);
        }
    }
    
    @Override
    public ConcealDeclare getDeclarationById(String declarationId)
    {
        return concealDeclareDao.getDeclarationById(declarationId);
    }
    
}