//
//  CryptoCoinModel+CoreDataMapper.swift
//  CryptoCoin
//
//  Created by Janesh Suthar
//

import Foundation
import Domain
import CoreData

extension CryptoCoinEntity {
    func toCoreData(context: NSManagedObjectContext) -> CryptoCoinCoreData {
        let coreDataModel = CryptoCoinCoreData(context: context)
        coreDataModel.id = self.id ?? UUID().uuidString
        coreDataModel.name = self.name
        coreDataModel.symbol = self.symbol
        coreDataModel.isActive = self.isActive
        coreDataModel.isNew = self.isNew
        coreDataModel.type = self.type
        return coreDataModel
    }
}

extension CryptoCoinCoreData {
    func toDomain() -> CryptoCoinEntity {
        return CryptoCoinEntity(
            name: self.name ?? "",
            symbol: self.symbol ?? "",
            type: self.type ?? "",
            isActive: self.isActive,
            isNew: self.isNew,
            id: self.id ?? UUID().uuidString
        )
    }
}
