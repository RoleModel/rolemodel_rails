import RoleModel from "@rolemodel/turbo-confirm"

Turbo.setConfirmMethod(RoleModel.confirm)

RoleModel.init()
