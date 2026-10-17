//  StoredOption.swift
//  Project List
//  StoredOption.swift
//  保存用のキー（rawValue）と、画面に出す名前（label）を分けるための仕組み

import Foundation

protocol StoredOption: RawRepresentable, CaseIterable where RawValue == String
{
    // 画面に表示する名前
    var label: String { get }
}

extension StoredOption
{
    // 保存された文字列から復元する（以前の日本語で保存されたデータにも対応）
    static func fromStored(_ value: String) -> Self?
    {
        Self(rawValue: value) ?? allCases.first { $0.label == value }
    }
}
