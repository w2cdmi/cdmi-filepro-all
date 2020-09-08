package com.huawei.sharedrive.uam.product.service;


import java.util.List;

import com.huawei.sharedrive.uam.product.domain.Product;


public interface ProductService {

	List<Product> list();

	Product get(long productId);
	
	List<Product> getUserProducts();
	
	List<Product> getUserProductsByTypeAndLevel(byte type, byte level);
}
