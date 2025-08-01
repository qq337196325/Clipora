// Copyright (c) 2025 Clipora.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.


const Map<String, String> homeGroupI18n = {
  // 分组页面主要内容
  'i18n_group_分组管理': 'การจัดการกลุ่ม',
  'i18n_group_管理你的内容分类': 'จัดการหมวดหมู่เนื้อหาของคุณ',
  'i18n_group_全部': 'ทั้งหมด',
  'i18n_group_所有内容': 'เนื้อหาทั้งหมด',
  'i18n_group_重要': 'สำคัญ',
  'i18n_group_标记重要': 'ทำเครื่องหมายเป็นสำคัญ',
  'i18n_group_归档': 'เก็บถาวร',
  'i18n_group_回收站': 'ถังขยะ',
  'i18n_group_全部文章': 'บทความทั้งหมด',
  'i18n_group_重要文章': 'บทความสำคัญ',
  'i18n_group_归档文章': 'บทความที่เก็บถาวร',
  
  // 分类相关
  'i18n_group_暂无分类': 'ยังไม่มีหมวดหมู่',
  'i18n_group_点击右上角添加按钮创建第一个分类': 'คลิกปุ่มเพิ่มที่มุมขวาบนเพื่อสร้างหมวดหมู่แรกของคุณ',
  'i18n_group_加载中': 'กำลังโหลด...',
  'i18n_group_个项目': ' รายการ',
  'i18n_group_主分类': 'หมวดหมู่หลัก',
  'i18n_group_子分类': 'หมวดหมู่ย่อย',
  
  // 操作相关
  'i18n_group_刷新成功': 'รีเฟรชสำเร็จ',
  'i18n_group_刷新失败': 'รีเฟรชล้มเหลว: @error',
  'i18n_group_分类创建成功': 'สร้างหมวดหมู่ "@name" สำเร็จ',
  'i18n_group_创建分类失败': 'สร้างหมวดหมู่ล้มเหลว: @error',
  'i18n_group_子分类创建成功': 'สร้างหมวดหมู่ย่อย "@name" สำเร็จ',
  'i18n_group_创建子分类失败': 'สร้างหมวดหมู่ย่อยล้มเหลว: @error',
  'i18n_group_分类更新成功': 'อัปเดตหมวดหมู่ "@name" สำเร็จ',
  'i18n_group_更新分类失败': 'อัปเดตหมวดหมู่ล้มเหลว: @error',
  'i18n_group_分类删除成功': 'ลบหมวดหมู่ "@name" สำเร็จ',
  'i18n_group_删除分类失败': 'ลบหมวดหมู่ล้มเหลว: @error',
  'i18n_group_获取分类信息失败': 'ไม่สามารถดึงข้อมูลหมวดหมู่: @error',
  
  // 添加分类对话框
  'i18n_group_请输入分类名称': 'กรุณาใส่ชื่อหมวดหมู่',
  'i18n_group_修改分类名称': 'แก้ไขชื่อหมวดหมู่',
  'i18n_group_选择图标': 'เลือกไอคอน',
  'i18n_group_已选择': 'เลือกแล้ว',
  'i18n_group_取消': 'ยกเลิก',
  'i18n_group_创建': 'สร้าง',
  'i18n_group_保存': 'บันทึก',
  'i18n_group_父分类': 'หมวดหมู่หลัก',
  'i18n_group_编辑分类': 'แก้ไขหมวดหมู่',
  
  // 分类操作菜单
  'i18n_group_添加子分类': 'เพิ่มหมวดหมู่ย่อย',
  'i18n_group_在此分类下创建子分类': 'สร้างหมวดหมู่ย่อยภายใต้หมวดหมู่นี้',
  'i18n_group_重命名': 'เปลี่ยนชื่อ',
  'i18n_group_修改分类名称和图标': 'แก้ไขชื่อและไอคอนหมวดหมู่',
  'i18n_group_删除': 'ลบ',
  'i18n_group_删除此分类': 'ลบหมวดหมู่นี้',
  
  // 删除分类对话框
  'i18n_group_删除分类': 'ลบหมวดหมู่',
  'i18n_group_确定要删除分类': 'คุณแน่ใจหรือว่าต้องการลบหมวดหมู่ "',
  'i18n_group_吗': '"?',
  'i18n_group_删除后目录下的文章将移到未分类': 'หลังจากลบ บทความ @count ชิ้นในหมวดหมู่นี้จะถูกย้ายไปยังไม่มีหมวดหมู่',
}; 